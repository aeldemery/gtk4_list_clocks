
public class Gtk4ListClock.MainWindow : Gtk.ApplicationWindow {
    // GLib.ListStore clocks_list_store;
    public MainWindow (Gtk.Application app) {
        Object (application: app);
    }

    construct {
        var clocks_list_store = new GLib.ListStore (typeof (Clock));

        /* local time */
        var clock = new Clock ("local", null);
        clocks_list_store.append (clock);

        /* UTC time */
        clock = new Clock ("UTC", new TimeZone.utc ());
        clocks_list_store.append (clock);

        /* A bunch of timezones with GTK hackers */
        clock = new Clock ("San Francisco", new TimeZone ("America/Los_Angeles"));
        clocks_list_store.append (clock);
        clock = new Clock ("Xalapa", new TimeZone ("America/Mexico_City"));
        clocks_list_store.append (clock);
        clock = new Clock ("Boston", new TimeZone ("America/New_York"));
        clocks_list_store.append (clock);
        clock = new Clock ("London", new TimeZone ("Europe/London"));
        clocks_list_store.append (clock);
        clock = new Clock ("Berlin", new TimeZone ("Europe/Berlin"));
        clocks_list_store.append (clock);
        clock = new Clock ("Moscow", new TimeZone ("Europe/Moscow"));
        clocks_list_store.append (clock);
        clock = new Clock ("New Delhi", new TimeZone ("Asia/Kolkata"));
        clocks_list_store.append (clock);
        clock = new Clock ("Shanghai", new TimeZone ("Asia/Shanghai"));
        clocks_list_store.append (clock);

        // var clock_list_item_factory = new GLib.Factor
        this.set_title ("Clocks");
        this.set_default_size (600, 400);

        var scrolled_win = new Gtk.ScrolledWindow ();
        this.set_child (scrolled_win);

        /* Create the factory that creates the listitems. Because we
         * used bindings above during setup, we only need to connect
         * to the setup signal.
         * The bindings take care of the bind step.
         */
        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect (setup_listitem_cb);

        var grid_view = new Gtk.GridView.with_factory (factory);
        grid_view.set_hscroll_policy (Gtk.ScrollablePolicy.NATURAL);
        grid_view.set_vscroll_policy (Gtk.ScrollablePolicy.NATURAL);

        var selection = new Gtk.NoSelection (clocks_list_store);
        grid_view.set_model (selection);

        scrolled_win.set_child (grid_view);
    }

    void setup_listitem_cb (Gtk.ListItemFactory factory, Gtk.ListItem list_item) {
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        list_item.set_child (box);

        /* First, we create an expression that gets us the clock from the listitem:
         * 1. Create an expression that gets the list item.
         * 2. Use that expression's "item" property to get the clock
         */
        Gtk.Expression expression, clock_expression;
        expression = new Gtk.ConstantExpression.for_value (list_item);
        clock_expression = new Gtk.PropertyExpression (typeof (Gtk.ListItem), expression, "item");

        /* Bind the clock's location to a label.
         * This is easy: We just get the "location" property of the clock.
         */
        expression = new Gtk.PropertyExpression (typeof (Clock), clock_expression, "location");

        /* Now create the label and bind the expression to it. */
        var location_label = new Gtk.Label (null);
        expression.bind (location_label, "label", location_label);
        box.append (location_label);

        /* Here we bind the item itself to a GdkPicture.
         * This is simply done by using the clock expression itself.
         */
        var picture = new Gtk.Picture ();
        clock_expression.bind (picture, "paintable", picture);
        box.append (picture);


        /* And finally, everything comes together.
         * We create a label for displaying the time as text.
         * For that, we need to transform the "GDateTime" of the
         * time property into a string so that the label can display it.
         */
        expression = new Gtk.PropertyExpression (typeof (Clock), clock_expression, "time");
        expression = new Gtk.CClosureExpression(typeof(string), null, {expression}, (Callback)convert_time_to_string, null, null);

        /* Now create the label and bind the expression to it. */
        var time_label = new Gtk.Label (null);
        expression.bind (time_label, "label", time_label);
        box.append (time_label);
    }

    public static string convert_time_to_string (Object image, DateTime time) {
        return time.format ("%x\n%X");
    }
}
