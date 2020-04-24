require "airtable"
require "http/client"

Airtable.config.api_key = ENV["AIRTABLE_API_KEY"]
Airtable.config.base_name = ENV["AIRTABLE_BASE_NAME"]
# Airtable.config.debug = "true"

BUILD_HOOK = ENV.fetch("NETLIFY_BUILD_HOOK", "")
SITE_DIR   = ENV.fetch("SITE_DIR", "")
if BUILD_HOOK.empty? && SITE_DIR.empty?
  puts "Need at least one of (NETLIFY_BUILD_HOOK, SITE_DIR)"
  exit 1
end

POLLING     = ENV.fetch("AIRTABLE_POLLING_SECONDS", "20").to_i
DEPLOY_WAIT = ENV.fetch("AIRTABLE_DEPLOY_WAIT", "60").to_i

class Produs < Airtable::Model
  def_wrappers("Preturi")

  JSON.mapping(
    produs: {type: String?, key: "Produs"},
    nota: {type: String?, key: "Nota"},
    pret_minim: {type: Float64?, key: "Pret Minim"},
    pret_maxim: {type: Float64?, key: "Pret Maxim"},
    imagine: {type: Array(Airtable::Image)?, key: "Imagine"}
  )

  def ==(other)
    @pret_minim == other.pret_minim &&
      @pret_maxim == other.pret_maxim &&
      @produs == other.produs &&
      @nota == other.nota &&
      @imagine == other.imagine
  end
end

deploy_channel = Channel(Nil).new
deploy_fiber : Fiber? = nil

def deploy_local
  puts `cd #{SITE_DIR} && yarn build`
end

def deploy_netlify
  resp = HTTP::Client.post(BUILD_HOOK, body: "{}")
  if resp.status == HTTP::Status::OK
    puts "Deployed successfully!\n"
  else
    puts "Deployment error!"
    puts resp.body
    puts "\n"
  end
end

def deploy(ch)
  loop do
    puts "Deploying in #{DEPLOY_WAIT} seconds..."
    select
    when ch.receive
      puts "\nAnother change detected"
      next
    when timeout(DEPLOY_WAIT.seconds)
      break
    end
  end

  puts "Deploying..."
  if !SITE_DIR.empty?
    deploy_local
  else
    deploy_netlify
  end
end

last_produse = Produs.list(
  filterByFormula: "{Published}",
  view: "Main View",
  maxRecords: 100,
  source: :backend
)

while true
  sleep POLLING.seconds
  begin
    produse = Produs.list(
      filterByFormula: "{Published}",
      view: "Main View",
      maxRecords: 100,
      source: :backend
    )
  rescue ex
    puts "Error fetching products:", ex.message
    next
  end

  if produse != last_produse
    last_produse = produse

    if deploy_fiber.nil? || deploy_fiber.dead?
      deploy_fiber = spawn deploy(deploy_channel)
    else
      deploy_channel.send(nil)
    end

    next
  end

  last_produse = produse
end
