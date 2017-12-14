class ScrappingController < ApplicationController
  def home
  end

  def search
      @var = ScrapFbPros.new.perform
  end
end
