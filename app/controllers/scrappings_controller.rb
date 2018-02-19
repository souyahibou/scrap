class ScrappingsController < ApplicationController

attr_accessor :var2, :client, :callback_url

  def initialize
      @var2 = "test"
      @scopes_auths = 'user_about_me, user_location, user_birthday,  user_posts, user_friends, read_custom_friendlists, user_relationship_details, user_relationships,  read_page_mailboxes, rsvp_event, user_events, manage_pages, user_managed_groups, pages_show_list, pages_manage_instant_articles, publish_pages, read_insights, read_custom_friendlists'
      @scopes_auths2 = 'offline_access,user_about_me,user_events,manage_pages,user_managed_groups'
      @scopes_auths3 ='public_profile,user_friends,email,public_profile'
      @client = FBGraph::Client.new(:client_id => ENV["FIRST_APP_ID"],:secret_id => Figaro.env.secret_id)
      @callback_url = 'http://localhost:3000/scrappings/request_code'
      @callback_url2 = 'http://localhost:3000/scrappings/response_code'
      @callback_url3 = 'https://www.facebook.com/connect/login_success.html'
  end
  # @oauth = Koala::Facebook::OAuth.new(ENV["FIRST_APP_ID"], Figaro.env.secret_id, @callback_url3)
  # @token = @oauth.get_app_access_token
  # @graph = Koala::Facebook::API.new(@token)
  # @graph.get_object("me")
  # @graph.get_object("2030602280286938?fields=events{photos{images}}")
  def home

  end

  def search2
      @var = ScrapUrlsPros.new.perform
      render :json => @var
  end

  def search
      @var = ScrapFbPros.new.perform
      render :json => @var
  end

  def connect

  end
#.response_type code or token or code%20token or granted_scopes
#.scope

  def request_code
      ScrapFbPros.new.okay
      # redirect_to @client.authorization.authorize_url(:redirect_uri => @callback_url2 , :scope => @scopes_auths)
      # $requete = client.authorization.authorize_url( :redirect_uri => @callback_url3)
      # redirect_to $requete
  end

  def response_code
      begin
        @access_token ||= @client.authorization.process_callback(params[:code], :redirect_uri =>  @callback_url2)
      rescue => monerreur
        @access_token ||= monerreur.message.scan(/"([^"]*)"/)[1][0]
      end

      @client.set_token(@access_token)
      ENV["token"] = @access_token.to_s
      render :json => @client.selection.me.info!.include(ENV["token"])
      # redirect_to search
  end


end
