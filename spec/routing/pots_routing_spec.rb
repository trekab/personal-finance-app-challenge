require "rails_helper"

RSpec.describe PotsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/pots").to route_to("pots#index")
    end

    it "routes to #new" do
      expect(get: "/pots/new").to route_to("pots#new")
    end

    it "routes to #edit" do
      expect(get: "/pots/1/edit").to route_to("pots#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/pots").to route_to("pots#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/pots/1").to route_to("pots#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/pots/1").to route_to("pots#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/pots/1").to route_to("pots#destroy", id: "1")
    end
  end
end
