$.fn.values = function(data) {
   var inps = $(this).find(":input").get();

    if(typeof data != "object") {
       // return all data
        data = {};

        $.each(inps, function() {
            if (this.name && (this.checked
                        || /select|textarea/i.test(this.nodeName)
                        || /text|hidden|password/i.test(this.type))) {
                data[this.name] = $(this).val();
            }
        });
        return data;
    } else {
        $.each(inps, function() {
            if (this.name && this.name in data) {
                if(this.type == "checkbox" || this.type == "radio") {
                    $(this).prop("checked", (data[this.name] == $(this).val()));
                } else if ('object' != typeof data[this.name] || data[this.name] == null) {
                    $(this).val(data[this.name]);
                } else {
                    $(this).val(JSON.stringify(data[this.name]));
                }
            } else if (this.type == "checkbox") {
                $(this).prop("checked", false);
            }
       });
       return $(this);
    }
};

$.fn.errors = function(data) {
   var inps = $(this).find(":input").get();

    if(typeof data == "object") {
        $.each(inps, function() {
            if (this.name && data[this.name]) {
                var $control_group = $(this).closest('.control-group')
                $control_group.addClass('error');
                $control_group.find('.help-inline').html(data[this.name]).show();
            }
       });
       return $(this);
    }
};
