# frozen_string_literal: true

require "google/apis"
require "google/apis/youtube_v3"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"
require "json"
require "yt/sub/version"

module Yt
  module Sub
    # The application class
    class App
      REDIRECT_URI = "urn:ietf:wg:oauth:2.0:oob"
      APPLICATION_NAME = "yt-sub"
      CLIENT_SECRETS_PATH = "client_secret.json"
      CREDENTIALS_PATH = File.join(Dir.home, ".credentials", "#{APPLICATION_NAME}.yaml")
      SCOPE = Google::Apis::YoutubeV3::AUTH_YOUTUBE_FORCE_SSL

      def initialize(opts)
        @opts = opts
        Google::Apis.logger = Logger.new(STDERR) if @opts[:verbose]
        @service = Google::Apis::YoutubeV3::YouTubeService.new
        FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))
        @service.client_options.application_name = APPLICATION_NAME
        @service.authorization = authorize
      end

      def authorize
        credentials = authorizer.get_credentials(user_id)
        credentials = ask_auth if credentials.nil?
        credentials
      end

      def client_id
        @client_id ||= Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
      end

      def token_store
        @token_store ||= Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
      end

      def authorizer
        @authorizer ||= Google::Auth::UserAuthorizer.new(
          client_id, SCOPE, token_store
        )
      end

      def user_id
        "default"
      end

      def ask_auth
        url = authorizer.get_authorization_url(base_url: REDIRECT_URI)
        puts "Open the following URL in the browser and enter the " \
             "resulting code after authorization"
        puts url
        code = gets
        authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: REDIRECT_URI
        )
      end

      def upload
        create_or_update_caption
      end

      def create_or_update_caption
        has_caption = caption?
        if has_caption
          update_caption(has_caption)
        else
          create_caption
        end
      end

      def caption?
        @service.list_captions(@opts[:video_id], "snippet").items.each do |cap|
          return cap.id if cap.snippet.language == @opts[:language] && cap.snippet.name == caption_snippet.name
        end
        false
      end

      def update_caption(id)
        @service.delete_caption(id)
        create_caption
      end

      def create_caption
        @service.insert_caption("snippet", caption_snippet, upload_source: @opts[:file])
      end

      def caption_snippet
        @caption_snippet ||= Google::Apis::YoutubeV3::CaptionSnippet.new(
          is_draft: false,
          language: @opts[:language],
          video_id: @opts[:video_id],
          name: ""
        )
      end
    end
  end
end
