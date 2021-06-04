/**
 * see https://github.com/thekelvinliu/country-code-emoji
 */
namespace Utils {
    public errordomain Error {
        INVALID_COUNTRY_CODE,
        INVALID_EMOJI,
    }
    // country code regex
    const string CC_REGEX = "^[a-z]{2}$";

    // flag emoji use 2 regional indicator symbols, and each symbol is 2 unichars
    const uint FLAG_LENGTH = 8;

    // offset between uppercase ascii and regional indicator symbols
    const uint OFFSET = 127397;

    public static string country_code_to_emoji (string country_code) throws Error {
        if (GLib.Regex.match_simple (CC_REGEX, country_code, GLib.RegexCompileFlags.CASELESS)) {
            var code = country_code.up ();
            unichar letter1 = code.get_char (0) + OFFSET;
            unichar letter2 = code.get_char (1) + OFFSET;
            var flag = "%s%s".printf (letter1.to_string (), letter2.to_string ());
            return flag;
        } else {
            throw new Error.INVALID_COUNTRY_CODE ("Couldn't parse country code: %s.\n", country_code);
        }
    }

    public static string emoji_to_country_code (string emoji) throws Error {
        if (emoji.length == FLAG_LENGTH) {
            unichar letter1 = emoji.get_char (0) - OFFSET;
            unichar letter2 = emoji.get_char (4) - OFFSET;
            var country_code = "%s%s".printf (letter1.to_string (), letter2.to_string ());
            return country_code.up ();
        } else {
            throw new Error.INVALID_EMOJI ("Emoji shoud be four characters: %s.\n", emoji);
        }
    }
}
