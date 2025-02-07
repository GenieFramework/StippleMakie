using Stipple
using Stipple.ReactiveTools
using StippleUI
import Genie.Server.openbrowser

using StippleMakie

Stipple.enable_model_storage(false)

# ------------------------------------------------------------------------------------------------

# if required set a different port, url or proxy_port for Makie's websocket communication, e.g. 8001
# if not specified, Genie's settings are applied for listen_url and proxy_url and Makie's (Bonito's) settings
# are applied for the ports
# configure_makie_server!(listen_port = 8001)

# Example settings for a proxy configuration:
# proxy_host and proxy_port will be taken from the serving port, just specify a different path
configure_makie_server!(listen_port = 8001, proxy_url = "/makie")
# specify the proxy_port explicitly
# configure_makie_server!(listen_port = 8001, proxy_url = "/makie", proxy_port = 8080)

startproxy(8080)

# in production settings it might be favorable to use a reverse proxy for the websocket communication, e.g. nginx.
# The appropriate nginx configuration can be generated using `nginx_config()` either after setting the configuration
# or by passing the desired settings directly to the function.
# nginx_config()

@app MakieDemo begin
    @out fig1 = MakieFigure()
    @out fig2 = MakieFigure()
    @in hello = false

    @onbutton hello @notify "Hello World!"

    @onchange isready begin
        init_makiefigures(__model__)
        # the viewport changes when the figure is ready to be written to
        onready(fig1) do
            Makie.scatter(fig1.fig[1, 1], (0:4).^3)
            Makie.heatmap(fig2.fig[1, 1], rand(5, 5))
            Makie.lines(fig2.fig[1, 2], cos.(0:2π/100:2π))
        end
    end
end


UI::ParsedHTMLString = column(style = "height: 80vh; width: 100%", [
    h4("MakiePlot 1")
    cell(col = 4, class = "full-width", makie_figure(:fig1))
    h4("MakiePlot 2")
    cell(col = 5, class = "full-width", makie_figure(:fig2))
    btn("Hello", @click(:hello), color = "primary")
])

ui() = UI

route("/") do
    WGLMakie.Page()
    global model = @init MakieDemo    
    html!(ui, layout = Stipple.ReactiveTools.DEFAULT_LAYOUT(head_content = [makie_dom(model)]), model = model, context = @__MODULE__)

    # alternatively, you can use the following line to render the page without the default layout
    # page(model, ui, prepend = makie_dom(model)) |> html
end

up()
openbrowser("http://localhost:8080")

# down()
# close_proxy(8080; force = true)
# close_all_proxies(force = true)