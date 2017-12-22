class ScrappingsController < ApplicationController
  def home

  end

  def search2
      @var = ScrapUrlsPros.new.perform
  end

  def search
      @var = ScrapFbPros.new.perform
  end
end
