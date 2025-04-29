module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags "ActionCable", current_user.username
    end

    private

    def find_verified_user
      user_id = cookies.signed[:user_id]
      logger.debug "ActionCable Connection: Attempting to find user with cookie user_id: #{user_id.inspect}" # Add this line

      if user_id && (verified_user = User.find_by(id: user_id))
        logger.debug "ActionCable Connection: Found verified user: #{verified_user.username} (ID: #{verified_user.id})" # Add this line
        verified_user
      else
        logger.warn "ActionCable Connection: REJECTING unauthorized connection. Cookie user_id: #{user_id.inspect}" # Add this line
        reject_unauthorized_connection
      end
    end
  end
end
