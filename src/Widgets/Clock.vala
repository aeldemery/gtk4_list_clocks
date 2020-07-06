
public class Gtk4ListClock.Clock : GLib.Object, Gdk.Paintable {

    /* We allow this to be NULL for the local timezone */
    public GLib.TimeZone ? time_zone { get; set; }

    public GLib.DateTime time {
        owned get {
            return get_the_time ();
        }
    }

    /* Name of the location we're displaying time for */
    public string location { get; set; }

    /* This is the list of all the ticking clocks */
    static Gee.ArrayList<Clock> ticking_clocks = null;

    /* This is the ID of the timeout source that is updating all
     * ticking clocks.
     */
    static uint ticking_clock_id = 0;

    static construct {
        ticking_clocks = new Gee.ArrayList<Clock> ();
    }

    public Clock (string location, TimeZone ? time_zone = null) {
        this.location = location;
        this.time_zone = time_zone;
        start_ticking ();
    }

    /* Here, we implement the functionality required by the GdkPaintable
     * interface. This way we have a trivial way to display an analog clock.
     * It also allows demonstrating how to directly use objects in the
     * listview later by making this object do something interesting.
     */
    public void snapshot (Gdk.Snapshot snapshot, double width, double height) {
        Gsk.RoundedRect outline = {};

        var w = (float) width;
        var h = (float) height;
        var gtksnapshot = (Gtk.Snapshot)snapshot;

        Gdk.RGBA black = { 0, 0, 0, 1 };

        var now = get_the_time ();

        /* save/restore() is necessary so we can undo the transforms we start
         * out with.
         */
        gtksnapshot.save ();

        /* First, we move the (0, 0) point to the center of the area so
         * we can draw everything relative to it.
         */
        gtksnapshot.translate ({ w / 2, h / 2 });

        /* Next we scale it, so that we can pretend that the clock is
         * 100px in size. That way, we don't need to do any complicated
         * math later. We use MIN() here so that we use the smaller
         * dimension for sizing. That way we don't overdraw but keep
         * the aspect ratio.
         */
        gtksnapshot.scale (float.min (w, h) /
                           100.0f, float.min (w, h) / 100.0f);

        /* Now we have a circle with diameter 100px (and radius 50px) that
         * has its (0, 0) point at the center. Let's draw a simple clock into it.
         */


        /* First, draw a circle. This is a neat little trick to draw a circle
         * without requiring Cairo.
         */
        outline.init_from_rect ({ { -50, -50 }, { 100, 100 } }, 50f);
        gtksnapshot.append_border (outline, /*Width of each boarder */ { 4, 4, 4, 4 }, { black, black, black, black });

        /* Next, draw the hour hand.
         * We do this using tranforms again: Instead of computing where the angle
         * points to, we just rotate everything and then draw the hand as if it
         * was :00. We don't even need to care about am/pm here because rotations
         * just work.
         */
        gtksnapshot.save ();
        gtksnapshot.rotate (30 * now.get_hour () + 0.5f * now.get_minute ());
        outline.init_from_rect ({ { -2, -23 }, { 4, 25 } }, 2f);
        gtksnapshot.push_rounded_clip (outline);
        gtksnapshot.append_color (black, outline.bounds);
        gtksnapshot.pop ();
        gtksnapshot.restore ();

        /* And the same as above for the minute hand. Just make this one longer
         * so people can tell the hands apart.
         */
        gtksnapshot.save ();
        gtksnapshot.rotate (6 * now.get_minute ());
        outline.init_from_rect ({ { -2, -43 }, { 4, 45 } }, 2f);
        gtksnapshot.push_rounded_clip (outline);
        gtksnapshot.append_color (black, outline.bounds);
        gtksnapshot.pop ();
        gtksnapshot.restore ();

        /* and finally, the second indicator. */
        gtksnapshot.save ();
        gtksnapshot.rotate (6 * now.get_second ());
        outline.init_from_rect ({ { -2, -43 }, { 4, 10 } }, 2f);
        gtksnapshot.push_rounded_clip (outline);
        gtksnapshot.append_color (black, outline.bounds);
        gtksnapshot.pop ();
        gtksnapshot.restore ();

        /* And finally, don't forget to restore the initial save() that
         * we did for the initial transformations.
         */
        gtksnapshot.restore ();
    }

    public int get_intrinsic_height () {
        return 100;
    }

    public int get_intrinsic_width () {
        return 100;
    }

    /* This function returns the current time in the clock's timezone. */
    GLib.DateTime get_the_time () {
        if (time_zone != null) {
            return new GLib.DateTime.now (time_zone);
        } else {
            return new GLib.DateTime.now_local ();
        }
    }

    /* Every second, this function is called to tell everybody that
     * the clocks are ticking.
     */
    bool tick () {
        foreach (var clock in ticking_clocks) {
            /* We will now return a different value for the time porperty,
             * so notify about that.
             */
            clock.notify_property ("time");
            // print("%p\n", clock);
            /* We will also draw the hands of the clock differently.
             * So notify about that, too.
             */
            clock.invalidate_contents ();
        }
        return GLib.Source.CONTINUE;
    }

    void start_ticking () {
        /* if no clock is ticking yet, start */
        if (ticking_clock_id == 0) {
            ticking_clock_id = GLib.Timeout.add_seconds (1, tick);
        }
        ticking_clocks.add (this);
    }

    void stop_ticking () {
        ticking_clocks.remove (this);
        /* If no clock is remaining, stop running the tick updates */
        if (ticking_clocks.size == 0 && ticking_clock_id != 0) {
            GLib.Source.remove (ticking_clock_id);
        }
    }

    ~Clock () {
        stop_ticking ();
    }
}
