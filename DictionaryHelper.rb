class DictionaryHelper
    @@abreviationArray = {
        " ACAMP " => " ACAMPAMENTO ",
        " AL " => " ALAMEDA ",
        " AV " => " AVENIDA ",
        " BL " => " BLOCO ",
        " BSQ " => " BOSQUE ",
        " CALC " => " CALCADA ",
        " CAM " => " CAMINHO ",
        " CPO " => " CAMPO ",
        " CAN " => " CANAL ",
        " CJ " => " CONJUNTO ",
        " JD " => " JARDIM ",
        " LD " => " LADEIRA ",
        " R " => " RUA ",
        " TER " => " TERMINAL ",
        " TV " => " TRAVESSA ",
        " TUN " => " TUNEL ",
        " VLE " => " VALE ",
        " V " => " VIA ",
        " VD " => " VIADUTO ",
        " VLA " => " VIELA ",
        " VL " => " VILA",
        "0" => "0.",
        "1" => "1.",
        "2" => "2.",
        "3" => "3.",
        "4" => "4.",
        "5" => "5.",
        "6" => "6.",
        "7" => "7.",
        "8" => "8.",
        "9" => "9."
    }

    def byExtense(string)
        string = string.gsub(",", " ")
        string = string.gsub(".", " ")
        string = string.gsub(";", " ")
        string = string.gsub("-", " ")
        string = string.gsub("/", " ")
        string = string.gsub("*", " ")
        @@abreviationArray.each do |key, value|
            string = string.gsub("#{key}", "#{value}")
        end
        string
    end
end
