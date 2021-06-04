// Copyright (c) 2021 Ahmed Eldemery
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

public class Gtk4ListClock.ClockFace : Gtk.Widget {
    GLib.TimeZone _time_zone;

    bool _ticking = false;
    uint _ticking_id = 0;

    GLib.DateTime _now;
    GLib.DateTime now {
        owned get {
            return new GLib.DateTime.now (_time_zone);
        }
        protected set {
            _now = value;
        }
    }

    public string time {
        owned get {
            return now.format ("%x\n%X");
        }
    }

    public ClockFace (string ? time_zone = null) {
        set_time_zone (time_zone);
        // sets a minimum size for this widget.
        //this.set_size_request (200, 200);
        start_ticking ();
    }

    public void set_time_zone (string ? timezone) {
        if (timezone == null) {
            this.now = new GLib.DateTime.now_utc ();
            try {
                this._time_zone = new GLib.TimeZone.identifier ("UTC");
            } catch (GLib.Error err) {
                GLib.error ("Gould not parse time zones: %s\n", err.message);
            }
        } else {
            try {
                var zone = new GLib.TimeZone.identifier (timezone);
                this.now = new GLib.DateTime.now (zone);
                this._time_zone = zone;
            } catch (GLib.Error err) {
                GLib.error ("Gould not parse time zones: %s\n", err.message);
            }
        }
        this.tick ();
    }

    /* Here, we implement the functionality required by the GdkPaintable
     * interface. This way we have a trivial way to display an analog clock.
     * It also allows demonstrating how to directly use objects in the
     * listview later by making this object do something interesting.
     */
    protected override void snapshot (Gtk.Snapshot snapshot) {
        Gsk.RoundedRect outline = {};

        var w = this.get_width ();
        var h = this.get_height ();

        Gdk.RGBA black = { 0, 0, 0, 1 };

        /* save/restore() is necessary so we can undo the transforms we start
         * out with.
         */
        snapshot.save ();

        /* First, we move the (0, 0) point to the center of the area so
         * we can draw everything relative to it.
         */
        snapshot.translate ({ w / 2, h / 2 });

        /* Next we scale it, so that we can pretend that the clock is
         * 100px in size. That way, we don't need to do any complicated
         * math later. We use MIN() here so that we use the smaller
         * dimension for sizing. That way we don't overdraw but keep
         * the aspect ratio.
         */
        snapshot.scale (float.min (w, h) /
                        100.0f, float.min (w, h) / 100.0f);

        /* Now we have a circle with diameter 100px (and radius 50px) that
         * has its (0, 0) point at the center. Let's draw a simple clock into it.
         */


        /* First, draw a circle. This is a neat little trick to draw a circle
         * without requiring Cairo.
         */
        outline.init_from_rect ({ { -50, -50 }, { 100, 100 } }, 50f);
        snapshot.append_border (outline, /*Width of each boarder */ { 4, 4, 4, 4 }, { black, black, black, black });

        /* Next, draw the hour hand.
         * We do this using tranforms again: Instead of computing where the angle
         * points to, we just rotate everything and then draw the hand as if it
         * was :00. We don't even need to care about am/pm here because rotations
         * just work.
         */
        snapshot.save ();
        snapshot.rotate (30 * now.get_hour () + 0.5f * now.get_minute ());
        outline.init_from_rect ({ { -2, -23 }, { 4, 25 } }, 2f);
        snapshot.push_rounded_clip (outline);
        snapshot.append_color (black, outline.bounds);
        snapshot.pop ();
        snapshot.restore ();

        /* And the same as above for the minute hand. Just make this one longer
         * so people can tell the hands apart.
         */
        snapshot.save ();
        snapshot.rotate (6 * now.get_minute ());
        outline.init_from_rect ({ { -2, -43 }, { 4, 45 } }, 2f);
        snapshot.push_rounded_clip (outline);
        snapshot.append_color (black, outline.bounds);
        snapshot.pop ();
        snapshot.restore ();

        /* and finally, the second indicator. */
        snapshot.save ();
        snapshot.rotate (6 * now.get_second ());
        outline.init_from_rect ({ { -2, -43 }, { 4, 10 } }, 2f);
        snapshot.push_rounded_clip (outline);
        snapshot.append_color (black, outline.bounds);
        snapshot.pop ();
        snapshot.restore ();

        /* And finally, don't forget to restore the initial save() that
         * we did for the initial transformations.
         */
        snapshot.restore ();
    }

    void start_ticking () {
        if (_ticking_id == 0) {
            _ticking = true;
            _ticking_id = GLib.Timeout.add_seconds (1, tick);
        }
    }

    void stop_ticking () {
        if (_ticking_id != 0) {
            _ticking = false;
            GLib.Source.remove (_ticking_id);
        }
    }

    bool tick () {
        this.queue_draw ();
        this.notify_property ("time");
        return GLib.Source.CONTINUE;
    }

    protected override void dispose () {
        base.dispose ();
        if (_ticking) {
            stop_ticking ();
        }
    }

    protected override void measure (Gtk.Orientation orientation, 
        int for_size, 
        out int minimum, 
        out int natural, 
        out int minimum_baseline, 
        out int natural_baseline) {
            minimum = 100;
            natural = 200;
            minimum_baseline = natural_baseline = -1;
    }
}
