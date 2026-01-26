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
#include <memory>

#include "ardour/libardour_visibility.h"
#include "ardour/session_handle.h"

namespace xdaw {
class Server;
struct SessionRequest;
struct SessionState;
struct TransportState;
struct Track;
struct EditBatch;
struct EditResponse;
struct RenderRequest;
}  // namespace xdaw

namespace ARDOUR {

class Session;

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
   * Process pending gRPC tasks. Call from GTK idle handler.
   */
  auto process_pending_tasks() -> void;

  /**
   * Check if tasks are pending and clear the flag atomically.
   * Returns true if tasks were pending.
   */
  [[nodiscard]] auto has_pending_tasks() -> bool;

 private:
  auto setup_handlers() -> void;

  // Handler implementations
  auto build_session_state(const xdaw::SessionRequest& req)
      -> xdaw::SessionState;
  auto build_transport_state() -> xdaw::TransportState;
  auto get_track_detail(const std::string& track_id) -> xdaw::Track;
  auto apply_edits(const xdaw::EditBatch& batch) -> xdaw::EditResponse;
  auto render_region(
      const xdaw::RenderRequest& req,
      std::function<void(const std::vector<float>&, bool, const std::string&)>
          writer) -> void;

  std::unique_ptr<xdaw::Server> server_;
  std::atomic<bool> tasks_pending_{false};
  std::int32_t port_;
};

}  // namespace ARDOUR
