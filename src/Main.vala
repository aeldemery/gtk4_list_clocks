/*
 * File: Main.vala
 * Created Date: Saturday June 6th 2020
 * Author: Ahmed Eldemery
 * Email: aeldemery.de@gmail.com
 * ---------
 * MIT License
 * http://www.opensource.org/licenses/MIT
 */


public class Gtk4ListClock.ClockApp : Gtk.Application {
    // Member variables

    // Constructor
    public ClockApp () {
        Object (application_id: "github.aeldemery.gtk4_list_clock",
                flags : GLib.ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var win = this.get_active_window ();
        if (win == null) {
            win = new MainWindow (this);
        }
        win.present ();
    }

    protected override void open (GLib.File[] files, string hint) {
    }

    static int main (string[] args) {
        var my_app = new ClockApp ();
        return my_app.run (args);
    }
}
