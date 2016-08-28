require 'capybara'
require 'capybara/dsl'

class SubmittalScraper
  include Capybara::DSL

  URL = "http://my.submittal123.com/"

  attr_reader :project, :session

  def initialize(project:)
    Capybara.register_driver :selenium_chrome do |app|
      Capybara::Selenium::Driver.new(app, :browser => :chrome)
    end

    Capybara.default_driver = :selenium_chrome

    @project = project
  end

  def run!
    visit URL

    login
    open_packages
    search_for_package
    view_package
    analyze_packages

    terminate!
  end

  def login
    fill_in('username', with: ENV.fetch('SUBMITTAL_USERNAME'))
    fill_in('password', with: ENV.fetch('SUBMITTAL_PASSWORD'))
    click_on('Login')
  end

  def open_packages
    el = find('#toolbar_submittalpackage_open')
    el.click
  end

  def search_for_package
    fill_in('namesearch', with: project.name)
  end

  def view_package
    within('#tbl_openpackage') do
      first('a').click
    end
  end

  def analyze_packages
    packages = []

    within('#packagelines') do
      els = all('li')

      els.each do |e|
        data = {}
        data[:type] = e.find('.linedetails_type').text
        data[:description] = e.find('.linedetails_description').text
        data[:manufacturer] = e.find('.linedetails_manufacturer').text
        data[:notes] = e.find('.linedetails_notes').text
        data[:window] = window_opened_by { e.find('a.linedocument_view').click }

        packages << data
      end
    end

    packages.each do |p|
      within_window p[:window] do
        save_page("#{Rails.root}/tmp/#{project.id}-#{SecureRandom.hex(4)}.pdf")
      end
    end

    packages.each do |p|
      cut_sheet = CutSheet.find_or_initialize_by({
        job_id: project.id,
        fixture_type: p[:type],
        description: p[:description],
        manufacturer: p[:manufacturer]
      })

      cut_sheet.notes = p[:notes]
      cut_sheet.pdf_url = "https://dl.dropboxusercontent.com/u/50206714/SwedishCovenantHospitalSuiteF804.pdf"
      cut_sheet.fixture_id = 1

      cut_sheet.save!
    end
  end

  def terminate!
    Capybara.reset_session!
    page.driver.quit
  end
end
