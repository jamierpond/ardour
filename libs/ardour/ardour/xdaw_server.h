/*
 * Copyright (C) 2025 XDAW Contributors
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#pragma once

#include <atomic>
#include <cstdint>
#include <map>
#include <memory>
#include <string>

#include "pbd/id.h"
#include "pbd/signals.h"

#include "ardour/libardour_visibility.h"
#include "ardour/session_handle.h"
#include "ardour/types.h"

// TODO CLAUDE THIS IS A FUCKING EMBARRASSMENT FIX IT
// THIS SHOULD BE DONE IN THE SDK NOT BY THE CONSUMER OF THE SDK
namespace xdaw {
class Server;
struct SessionRequest;
struct SessionState;
struct TransportState;
struct Track;
struct EditBatch;
struct EditResponse;
struct RenderRequest;
struct RenderOperation;
struct PluginsRequest;
struct PluginsResponse;
}  // namespace xdaw

namespace ARDOUR {

class Route;
class Session;
typedef std::list<std::shared_ptr<Route>> RouteList;

/**
 * XDAWServer provides a gRPC interface for remote control of Ardour.
 *
 * The server runs alongside the GTK UI, using GTK idle callbacks to
 * process gRPC tasks on the main thread. This ensures thread-safe
 * access to the Session.
 */
class LIBARDOUR_API XDAWServer : public SessionHandlePtr {
 public:
  explicit XDAWServer(std::int32_t port = 50051);
  ~XDAWServer();

  XDAWServer(const XDAWServer&) = delete;
  auto operator=(const XDAWServer&) -> XDAWServer& = delete;

  auto set_session(Session* s) -> void override;
  auto start() -> void;
  auto stop() -> void;
  [[nodiscard]] auto is_running() const -> bool;

  /**
   * Start pairing mode. Generates a PIN and emits PinDisplayRequest.
   * Returns the generated PIN.
   */
  [[nodiscard]] auto start_pairing_mode() -> std::string;

  /**
   * Cancel pairing mode. Emits PinDismissRequest.
   */
  auto cancel_pairing_mode() -> void;

  /**
   * Check if pairing mode is active.
   */
  [[nodiscard]] auto is_pairing_active() const -> bool;

  /**
   * Process pending gRPC tasks. Call from GTK idle handler.
   */
  auto process_pending_tasks() -> void;

  /**
   * Check if tasks are pending and clear the flag atomically.
   * Returns true if tasks were pending.
   */
  [[nodiscard]] auto has_pending_tasks() -> bool;

  /**
   * Signal emitted when a PIN should be displayed for pairing.
   * The string parameter is the 6-digit PIN to show to the user.
   */
  PBD::Signal<void(std::string)> PinDisplayRequest;

  /**
   * Signal emitted when the PIN dialog should be dismissed.
   */
  PBD::Signal<void()> PinDismissRequest;

 private:
  auto setup_handlers() -> void;

  // Handler implementations
  auto build_session_state(const xdaw::SessionRequest& req)
      -> xdaw::SessionState;
  auto build_transport_state() -> xdaw::TransportState;
  auto get_track_detail(const std::string& track_id) -> xdaw::Track;
  auto get_plugins(const xdaw::PluginsRequest& req) -> xdaw::PluginsResponse;
  auto apply_edits(const xdaw::EditBatch& batch) -> xdaw::EditResponse;

  // Async render: starts export and returns operation ID immediately.
  // Completion notification is sent via server_->push_notification().
  auto start_render(const xdaw::RenderRequest& req) -> xdaw::RenderOperation;

  // Called periodically to check for completed renders and send notifications
  auto check_pending_renders() -> void;

  // Override from SessionHandlePtr
  auto session_going_away() -> void override;

  // Subscribe to session/route signals for push notifications
  auto subscribe_to_session_signals() -> void;
  auto subscribe_to_route_signals(std::shared_ptr<ARDOUR::Route> route) -> void;
  auto subscribe_to_processor_params(std::shared_ptr<ARDOUR::Route> route,
                                      PBD::ScopedConnectionList& connections) -> void;
  auto unsubscribe_all() -> void;

  // Signal handlers
  auto on_routes_added(ARDOUR::RouteList& routes) -> void;
  auto on_mixer_control_changed(std::shared_ptr<ARDOUR::Route> route,
                                 const std::string& track_id,
                                 const std::string& control_name,
                                 double value) -> void;
  auto on_transport_state_changed() -> void;
  auto on_position_changed(samplepos_t position) -> void;
  auto on_playlist_changed(const std::string& track_id) -> void;

  std::unique_ptr<xdaw::Server> server_;
  std::atomic<bool> tasks_pending_{false};
  std::atomic<bool> applying_edits_{false};  // Reentrancy guard for apply_edits

  // Signal connections - cleared when session changes
  PBD::ScopedConnectionList session_connections_;
  std::map<PBD::ID, PBD::ScopedConnectionList> route_connections_;

  // Track pending render operations
  struct PendingRender {
    std::string operation_id;
    std::string output_path;
    bool stream_response;
  };
  std::vector<PendingRender> pending_renders_;
};

}  // namespace ARDOUR
