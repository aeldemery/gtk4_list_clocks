// Copyright (c) 2021 Ahmed Eldemery
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

public class Gtk4ListClock.MainWindow : Gtk.ApplicationWindow {
    // GLib.ListStore clocks_list_store;
    public MainWindow (Gtk.Application app) {
        Object (application: app);
    }

    construct {
        var css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource ("/listclocks/Styles/Application.css");
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);

        var clocks_list_model = new TimezonesListModel ();

        // var clock_list_item_factory = new GLib.Factor
        this.set_title ("Clocks");
        this.set_default_size (1200, 800);

        var scrolled_win = new Gtk.ScrolledWindow ();
        this.set_child (scrolled_win);

        /* Create the factory that creates the listitems. Because we
         * used bindings above during setup, we only need to connect
         * to the setup signal.
         * The bindings take care of the bind step.
         */
        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect (setup_listitem_cb);
        factory.bind.connect (bind_listitem_cb);

        var selection = new Gtk.NoSelection (clocks_list_model);

        var grid_view = new Gtk.GridView (selection, factory);
        grid_view.max_columns = 12;
        grid_view.set_hscroll_policy (Gtk.ScrollablePolicy.NATURAL);
        grid_view.set_vscroll_policy (Gtk.ScrollablePolicy.NATURAL);

        scrolled_win.set_child (grid_view);
    }

    void setup_listitem_cb (Gtk.ListItemFactory factory, Gtk.ListItem list_item) {
        var clock_info_display = new ClockInfoDisplay ();
        list_item.set_child (clock_info_display);
    }

    void bind_listitem_cb (Gtk.ListItemFactory factory, Gtk.ListItem list_item) {
        var timezone_info = list_item.get_item () as TimezoneInfo;
        var clock_info_display = list_item.get_child () as ClockInfoDisplay;

        clock_info_display.set_time_zone_info (timezone_info);
    }
}
