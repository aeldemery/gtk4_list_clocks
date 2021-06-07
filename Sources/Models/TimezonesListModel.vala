// Copyright (c) 2021 Ahmed Eldemery
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

public class Gtk4ListClock.TimezonesListModel : GLib.Object, GLib.ListModel {
    Gee.ArrayList<TimezoneInfo> entries = new Gee.ArrayList<TimezoneInfo>();

    public TimezonesListModel () {
        try {
            var data = GLib.resources_lookup_data (
                "/listclocks/Data/zone1970.tab",
                GLib.ResourceLookupFlags.NONE
            );

            var lines = ((string) data.get_data ()).split ("\n");
            foreach (var line in lines) {
                if ((line.get (0) == '#') || (line.get (0) == '\0')) {
                    continue;
                }
                var fields = line.split ("\t");
                // fields[3] which is the comments column could be null.
                var entry = new TimezoneInfo (fields[0], fields[1], fields[2], fields[3] ?? null);
                entries.add (entry);
            }
        } catch (GLib.Error error) {
            critical ("Couldn't parse time zones file, error: %s\n", error.message);
        }
    }

    public uint get_n_items () {
        return entries.size;
    }

    public GLib.Type get_item_type () {
        return typeof (TimezoneInfo);
    }

    public GLib.Object ? get_item (uint position) {
        if (position > entries.size) {
            return null;
        }
        return entries[(int) position];
    }
}
