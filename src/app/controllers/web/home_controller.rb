module Web
  class HomeController < ApplicationController
    def show
      result = Quotes::UseCases::FetchDailyQuote.new.call

      @quote_text = result.quote.quote_text.value
      @display_date = result.jst_date.strftime("%Y.%m.%d")
    end
  end
end
