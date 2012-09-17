require 'twitter_app'
require 'user'

class PagesController < ApplicationController
  respond_to :html, :json
  include TwitterApp
  
  def index
    @pages = Page.desc(:$natural).limit(30).to_a
    respond_with(@pages)
  end
 
  def search
    uri = params[:uri]
    limit = params[:limit].to_i
    begin
      pages = Page.where(:uri => uri).limit(limit).desc(:updated).to_a
    rescue => e
      pages = []
    end
    respond_to do |format|
      json = {:rows => pages}.to_json()
      format.html {render :json => json}
      format.json {render :json => json}
    end
  end
  
  def create
    if request.post?
      begin
        row = params
        row.delete(:controller)
        row.delete(:action)
        if current_user
          row[:twitter] = {
            :id => current_user.uid,
            :image => current_user.info['image'],
            :nickname => current_user.info['nickname'],
            :location => current_user.info['location'],
            :twitter => current_user.info['urls']['Twitter'],
          }
        end
        row = Page.create!(row)
        id = row[:_id]
        
        # 投稿
        #if current_user && params[:post_twitter]
        if current_user
          text = self.create_text(row)
          self.status_update(text)
        end
        
      rescue => e
        id = nil
        logger.error(sprintf("%s", e.message))
      end
    end
    respond_to do |format|
      json = {:id => id}.to_json
      format.html {render :json => json}
      format.json {render :json => json}
    end
  end
  
  def update
    if request.put?
      begin
        id = params[:_id]
        row = Page.find(id)
        if params[:text].empty?
          row.destroy
        else
          row[:text] = params[:text]
          row[:tags] = params[:tags]
          row.save!
        end
      rescue => e
        row = {}
        logger.error(sprintf("%s", e.message))
      end
    end
    respond_to do |format|
      json = {:id => id}.to_json
      format.html {render :json => json}
      format.json {render :json => json}
    end
  end
  
  def delete
    if request.delete?
      begin
        id = params[:_id]
        row = Page.find(id)
        if row
          row.destroy
        end
      rescue => e
        row = {}
        logger.error(sprintf("%s", e.message))
      end
    end
    respond_to do |format|
      json = {}
      format.html {render :json => json}
      format.json {render :json => json}
    end
  end
end
