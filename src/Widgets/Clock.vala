namespace Gtk4ListClock {
    public class Clock : Gtk.Widget {

        /* We allow this to be NULL for the local timezone */
        public GLib.TimeZone ? time_zone { get; set; }

        public GLib.DateTime time {
            owned get {
                return get_the_time ();
            }
        }

        public string time_to_string {
            owned get {
                return this.time.format ("%x\n%X");
            }
        }

        /* Name of the location we're displaying time for */
        public string location { get; set; }

        /* This is the list of all the ticking clocks */
        GLib.SList<Clock> ticking_clocks = null;

        /* This is the ID of the timeout source that is updating all
         * ticking clocks.
         */
        static uint ticking_clock_id = 0;

        construct {
            this.set_size_request (100, 100);
            ticking_clocks = new GLib.SList<Clock> ();
            start_ticking ();
        }

        public Clock (string location, TimeZone ? time_zone = null) {
            this.location = location;
            this.time_zone = time_zone;
        }

        /* Here, we implement the functionality required by the GdkPaintable
         * interface. This way we have a trivial way to display an analog clock.
         * It also allows demonstrating how to directly use objects in the
         * listview later by making this object do something interesting.
         */
        public override void snapshot (Gtk.Snapshot snapshot) {
            Gsk.RoundedRect outline = {};
            var width = this.get_width ();
            var height = this.get_height ();

            /* save/restore() is necessary so we can undo the transforms we start
             * out with.
             */
            snapshot.save ();

            /* First, we move the (0, 0) point to the center of the area so
             * we can draw everything relative to it.
             */
            Graphene.Point center = { width / 2, height / 2 };
            snapshot.translate (center);

            /* Next we scale it, so that we can pretend that the clock is
             * 100px in size. That way, we don't need to do any complicated
             * math later. We use MIN() here so that we use the smaller
             * dimension for sizing. That way we don't overdraw but keep
             * the aspect ratio.
             */
            snapshot.scale (float.min (width, height) / 100.0f, float.min (width, height) / 100.0f);

            /* Now we have a circle with diameter 100px (and radius 50px) that
             * has its (0, 0) point at the center. Let's draw a simple clock into it.
             */
            // var time = get_time ();

            /* First, draw a circle. This is a neat little trick to draw a circle
             * without requiring Cairo.
             */
            Graphene.Point origin = { -50, -50 };
            Graphene.Size size = { 100, 100 };
            outline.init_from_rect ({ origin, size }, 50);
            Gdk.RGBA black = { 0, 0, 0, 1 };
            snapshot.append_border (outline, /*Width of each boarder */ { 4, 4, 4, 4 }, { black, black, black, black });

            /* Next, draw the hour hand.
             * We do this using tranforms again: Instead of computing where the angle
             * points to, we just rotate everything and then draw the hand as if it
             * was :00. We don't even need to care about am/pm here because rotations
             * just work.
             */
            snapshot.save ();
            snapshot.rotate (30 * this.time.get_hour () + 0.5f * this.time.get_minute ());
            origin = { -2, -23 };
            size = { 4, 25 };
            outline.init_from_rect ({ origin, size }, 2);
            snapshot.push_rounded_clip (outline);
            snapshot.append_color (black, outline.bounds);
            snapshot.pop ();
            snapshot.restore ();

            /* And the same as above for the minute hand. Just make this one longer
             * so people can tell the hands apart.
             */
            snapshot.save ();
            snapshot.rotate (6 * this.time.get_minute ());
            origin = { -2, -43 };
            size = { 4, 45 };
            outline.init_from_rect ({ origin, size }, 2);
            snapshot.push_rounded_clip (outline);
            snapshot.append_color (black, outline.bounds);
            snapshot.pop ();
            snapshot.restore ();

            /* and finally, the second indicator. */
            snapshot.save ();
            snapshot.rotate (6 * this.time.get_second ());
            origin = { -2, -43 };
            size = { 4, 10 };
            outline.init_from_rect ({ origin, size }, 2);
            snapshot.push_rounded_clip (outline);
            snapshot.append_color (black, outline.bounds);
            snapshot.pop ();
            snapshot.restore ();

            /* And finally, don't forget to restore the initial save() that
             * we did for the initial transformations.
             */
            snapshot.restore ();
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
                /* We will also draw the hands of the clock differently.
                 * So notify about that, too.
                 */
                clock.queue_draw ();
            }
            return GLib.Source.CONTINUE;
        }

        void stop_ticking () {
            ticking_clocks.remove (this);
            /* If no clock is remaining, stop running the tick updates */
            if (ticking_clocks.length () == 0 && ticking_clock_id != 0) {
                GLib.Source.remove (ticking_clock_id);
            }
        }

        void start_ticking () {
            /* if no clock is ticking yet, start */
            if (ticking_clock_id == 0) {
                ticking_clock_id = GLib.Timeout.add_seconds (1, tick);
            }
            ticking_clocks.prepend (this);
        }

        ~Clock () {
            stop_ticking ();
        }
    }
}