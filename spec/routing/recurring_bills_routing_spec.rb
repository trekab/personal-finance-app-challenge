require "rails_helper"

RSpec.describe RecurringBillsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/recurring_bills").to route_to("recurring_bills#index")
    end

    it "routes to #new" do
      expect(get: "/recurring_bills/new").to route_to("recurring_bills#new")
    end

    it "routes to #show" do
      expect(get: "/recurring_bills/1").to route_to("recurring_bills#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/recurring_bills/1/edit").to route_to("recurring_bills#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/recurring_bills").to route_to("recurring_bills#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/recurring_bills/1").to route_to("recurring_bills#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/recurring_bills/1").to route_to("recurring_bills#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/recurring_bills/1").to route_to("recurring_bills#destroy", id: "1")
    end
  end
end
