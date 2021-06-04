public class Gtk4ListClock.TimezoneInfo : GLib.Object {
    public TimezoneInfo (string countries, string coordinates, string timezone, string ? comments = null) {
        this.coordinates = coordinates;
        this.timezone = timezone;
        this.comments = comments;

        if (countries.contains (",")) {
            country_list = countries.split (",");
        } else {
            country_list = {countries};
        }
    }

    public string[] country_list;
    public string coordinates;
    public string timezone;
    public string ? comments;
}
