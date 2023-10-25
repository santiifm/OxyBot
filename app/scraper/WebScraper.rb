require 'selenium-webdriver'

class WebScraper

  def initialize
    @driver = Selenium::WebDriver.for :chrome
    @base_url = 'https://oxygeno.misactividades.com'
    @wait = Selenium::WebDriver::Wait.new(timeout: 10)
  end

  def start_scrape
    # Llenar variables con los datos respectivos dependiendo del día
    if Time.zone.now.strftime("%A") == "Sunday"
      day = "lunes"
      time = "20:00"
    elsif Time.zone.now.strftime("%A") == "Tuesday"
      day = "miércoles"
      time = "19:00"
    elsif Time.zone.now.strftime("%A") == "Thursday"
      day = "viernes"
      time = "18:00"
    else
      puts "Hoy es día de disfrutar, no reservar gimnasio 😎"
      @driver.quit
    end

    # Ir a página de login
    @driver.get("#{@base_url}/#login")

    # Rellenar campos del formulario
    email_field = @driver.find_element(id: 'email')
    password_field = @driver.find_element(id: 'password')

    email_field.send_keys('flecha.mrc@hotmail.com')
    password_field.send_keys('Maristarugby')

    # Apretar el botón de login
    login_button = @driver.find_element(:xpath, '//a[@href="javascript:void(0)" and @name="action"]')
    login_button.click
    sleep 2

    # Ir hasta la página de reservas
    @driver.get("#{@base_url}/#bookings")

    # Buscar el día que se quiere reservar
    day_div = @wait.until { @driver.find_element(:xpath, "//div[contains(@class, 'row booking-by-date black amber-text text-accent-4')][.//div[contains(text(), '#{day}')]]") }

    # Buscar el horario a reservar
    booking_div = @wait.until { day_div.find_element(:xpath, "following-sibling::div[@data-activity='GIMNASIO' and @data-time='#{time}']") }
    booking_div.click

    # Clickear botón de reserva
    register_class_button = @wait.until { @driver.find_element(:xpath, '//a[@id="register" and @href="#!"]') }
    register_class_button.click
    sleep 0.5

    begin
      # Clickear botón de confirmar reserva
      confirm_button = @driver.find_element(:xpath, '//a[@id="modalBookingConditionsConfirm" and @href="javascript:void(0)"]')
      confirm_button.click

      puts "Incripto en la clase del #{day} a las #{time}!"
    rescue Selenium::WebDriver::Error::ElementNotInteractableError
      # Si no encuentra botón de confirmación es porque se canceló la reserva
      puts "Inscripción del #{day} a las #{time} cancelada"
    end
  end
end
