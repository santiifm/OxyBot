require 'selenium-webdriver'

class WebScraper

  def initialize
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    @driver = Selenium::WebDriver.for :chrome, options: options
    @base_url = 'https://oxygeno.misactividades.com'
    @wait = Selenium::WebDriver::Wait.new(timeout: 1)
    @wait_input = Selenium::WebDriver::Wait.new(timeout: 200)
  end

  def start_scrape
    # Llenar variables con los datos respectivos dependiendo del día
    if Time.zone.now.strftime("%A") == "Sunday"
      @day = "lunes"
      @time = "20:00"
      @activity = "GIMNASIO"
    elsif Time.zone.now.strftime("%A") == "Tuesday"
      @day = "miércoles"
      @time = "19:00"
      @activity = "GIMNASIO"
    elsif Time.zone.now.strftime("%A") == "Thursday"
      @day = "jueves"
      @time = "18:00"
      @activity = "GIMNASIO"
    elsif Time.zone.now.strftime("%A") == "Saturday"
      puts "Hoy es día de disfrutar, no reservar gimnasio 😎"
      @driver.quit
    else
      @day = I18n.t("date.day_names.#{Time.zone.now.strftime('%A')}").downcase
    end

    # Ir a página de login
    @driver.get("#{@base_url}/#login")

    # Rellenar campos del formulario
    email_field = @wait.until { @driver.find_element(id: 'email') }
    password_field = @driver.find_element(id: 'password')

    email_field.send_keys('flecha.mrc@hotmail.com')
    password_field.send_keys('Maristarugby')

    # Apretar el botón de login
    login_button = @driver.find_element(:xpath, '//a[@href="javascript:void(0)" and @name="action"]')
    login_button.click
    sleep 1.5

    # Ir hasta la página de reservas
    @driver.get("#{@base_url}/#bookings")

    # Buscar el día que se quiere reservar
    day_div = @wait.until { @driver.find_element(:xpath, "//div[contains(@class, 'row booking-by-date black amber-text text-accent-4')][.//div[contains(text(), '#{@day}')]]") }

    # Fijarse si hay clase reservada
    begin
      booking_div = @wait.until { day_div.find_element(:xpath, "following-sibling::div[@class='row green white-text booking-by-date']") }
      @activity = booking_div.attribute('data-activity')
      @time = booking_div.attribute('data-time')
      booking_div.click
    rescue
      # Si no hay clase reservada buscar el horario a reservar
      booking_div = @wait.until { day_div.find_element(:xpath, "following-sibling::div[@data-activity='#{@activity}' and @data-time='#{@time}']") }
      booking_div.click
    end

    # Buscar y clickear botón de reservar
    begin
      register_class_button = @wait.until { @driver.find_element(:xpath, '//a[@class="btn grey amber-text text-accent-3 waves-effect waves-light btn-ma2" and @id="register" and @href="#!"]') }
      register_class_button.click
      sleep 0.5
    rescue Selenium::WebDriver::Error::TimeoutError
      # Si no hay botón de reservar (osea que solo queda el de anular) corroborar decisión de cancelación
      check_cancellation
    end

    begin
      # Clickear botón de confirmar reserva
      confirm_button = @driver.find_element(:xpath, '//a[@id="modalBookingConditionsConfirm" and @href="javascript:void(0)"]')
      confirm_button.click

      puts "Incripto en la clase de #{@activity.titleize} del #{@day} a las #{@time}!"
    rescue Selenium::WebDriver::Error::ElementNotInteractableError
      # Si no encuentra botón de confirmación es porque se canceló la reserva
      puts "Inscripción a #{@activity.titleize} del #{@day} a las #{@time} cancelada."
    end
  end

  # Método que pregunta al usuario si de verdad quiere cancelar el turno
  def check_cancellation
    print "Vas a cancelar la clase de de #{@activity.titleize} del #{@day} a las #{@time}, estas seguro?(si/no): "
    user_input = @wait_input.until { STDIN.gets.strip }
    if user_input == 'si'
      register_class_button = @wait.until { @driver.find_element(:xpath, '//a[@id="register" and @href="#!"]') }
      register_class_button.click
    elsif user_input == 'no'
      @driver.quit
    else
      puts 'Entrada no válida, intente de nuevo.'
      check_cancellation
    end
  end
end
