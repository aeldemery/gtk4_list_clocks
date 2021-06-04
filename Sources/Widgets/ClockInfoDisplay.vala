// Copyright (c) 2021 Ahmed Eldemery
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

public class Gtk4ListClock.ClockInfoDisplay : Gtk.Widget {
    Gtk.Label flags_label;
    Gtk.Label time_zone_label;
    Gtk.Label time_label;

    Gtk.Box vbox;
    ClockFace clock_face;

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    public ClockInfoDisplay () {
        time_zone_label = new Gtk.Label ("==");
        flags_label = new Gtk.Label ("==");
        time_label = new Gtk.Label ("==");

        clock_face = new ClockFace ();

        vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 4);
        vbox.append (time_zone_label);
        vbox.append (flags_label);
        vbox.append (clock_face);
        vbox.append (time_label);

        
        vbox.set_parent (this);
    }

    public void set_time_zone_info (TimezoneInfo info) {
        time_zone_label.label = info.timezone;

        var flags = "";
        try {
            foreach (var country in info.country_list) {
                flags += Utils.country_code_to_emoji (country) + " ";
            }
        } catch (Utils.Error err) {
            GLib.critical ("%s.\n", err.message);
        }
        flags_label.label = flags;

        clock_face.set_time_zone (info.timezone);

        var object_expression = new Gtk.ObjectExpression (clock_face);
        var property_expression = new Gtk.PropertyExpression (typeof (ClockFace), object_expression, "time");
        property_expression.bind (time_label, "label", time_label);
    }

    protected override void dispose () {
        base.dispose ();
        vbox.unparent ();
    }
}