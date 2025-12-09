require 'rails_helper'

RSpec.describe "users/new", type: :view do
  # Before each test, assign an un-persisted User object to @user
  # to simulate the controller action.
  before do
    @user = assign(:user, User.new)
  end

  # --- View Content Checks ---
  describe "Form Elements and Content" do
    before do
      # Render the view template
      render
    end

    it "displays the correct heading" do
      expect(rendered).to have_selector('h2', text: 'Sign up')
    end

    # spec/views/user/new.html.erb_spec.rb

    it "renders a form pointing to the users creation path" do
      expect(rendered).to have_selector("form") do
        expect(rendered).to have_field('user[name]')
        expect(rendered).to have_field('user[email_address]')
        expect(rendered).to have_field('user[password]')
      end
    end

    it "renders the 'Name' input field" do
      expect(rendered).to have_field('user[name]', type: 'text')
      expect(rendered).to have_selector("input[placeholder='Enter your full names']")
      expect(rendered).to have_selector("input[required='required']")
    end

    it "renders the 'Email' input field" do
      expect(rendered).to have_field('user[email_address]', type: 'email')
      expect(rendered).to have_selector("input[placeholder='Enter your email address']")
      expect(rendered).to have_selector("input[autocomplete='email_address']")
    end

    it "renders the 'Password' input field" do
      expect(rendered).to have_field('user[password]', type: 'password')
      expect(rendered).to have_selector("input[placeholder='Enter your password']")
      expect(rendered).to have_selector("input#password-field")
      expect(rendered).to have_selector("input[maxlength='72']")
    end

    it "displays the password requirement text" do
      expect(rendered).to have_selector('div', text: 'Password must be atleast 8 characters')
    end

    it "renders the submit button" do
      expect(rendered).to have_button('Create Account')
    end

    it "renders the link to the login page" do
      expect(rendered).to have_link('Login', href: new_session_path)
    end

    it "includes the mail icon SVG for email" do
      # Checking for a unique SVG path or class to ensure the icon is present
      expect(rendered).to have_selector("svg.lucide-mail-icon")
    end

    it "includes the toggle password mechanism (eye icons)" do
      expect(rendered).to have_selector('div#toggle-password')
      expect(rendered).to have_selector('svg#eye-open')
      expect(rendered).to have_selector('svg#eye-closed.hidden')
    end
  end

  describe "Pre-populating fields on failure" do
    it "pre-populates name and email_address fields from params on re-render" do
      params[:name] = "Incomplete User"
      params[:email_address] = "bad@email"

      render

      expect(rendered).to have_field('user[name]', with: 'Incomplete User')
      expect(rendered).to have_field('user[email_address]', with: 'bad@email')

      expect(rendered).to have_field('user[password]')
    end
  end

  # --- JavaScript / Functionality Check (Simulated) ---
  # Note: Actual JS execution requires a feature spec (Capybara/System Test),
  # but we can verify the necessary elements for the JS to work are present.
  describe "JavaScript elements" do
    before { render }

    it "includes the inline script tag" do
      # Check that the <script> block is present in the rendered output
      expect(rendered).to include("<script>")
    end

    it "includes necessary JS element IDs" do
      # Verify all required DOM element IDs for the script are present
      expect(rendered).to have_selector('#password-field')
      expect(rendered).to have_selector('#toggle-password')
      expect(rendered).to have_selector('#eye-open')
      expect(rendered).to have_selector('#eye-closed')
    end
  end
end
