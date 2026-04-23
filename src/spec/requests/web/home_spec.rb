require "rails_helper"

RSpec.describe "Web::Home", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to(Time.utc(2026, 4, 22, 15, 0, 0)) { example.run } # JST: 2026-04-23 00:00
  end

  it "renders heading, quote, and JST date" do
    Quote.create!(text: "一日一善。")

    get "/"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("本日の一言")
    expect(response.body).to include("一日一善。")
    expect(response.body).to include("2026.04.23")
  end

  it "returns 500 when quotes are empty" do
    get "/"

    expect(response).to have_http_status(:internal_server_error)
  end
end
