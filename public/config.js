$(document).ready(function () {

    $(function() {
        $('#setServerAddress').submit(function(event) {
            event.preventDefault(); 
            var form = $(this);
            $.ajax({
                type: form.attr('method'),
                url: form.attr('action'),
                data: form.serialize(),
                success:function() {
                updateServerAddress();
                updateConfigForm();
                }
            })
        });
    });

    $(function() {
        $('#resetServerAddress').submit(function(event) {
            event.preventDefault(); 
            var form = $(this);
            $.ajax({
                type: form.attr('method'),
                url: form.attr('action'),
                success:function(data) {
                updateServerAddress();
                updateConfigForm();
                }
            })
        });
    });

    $(function() {
        $('#setGlobalDelay').submit(function(event) {
            event.preventDefault(); 
            var form = $(this);
            $.ajax({
                type: form.attr('method'),
                url: form.attr('action'),
                data: form.serialize(),
                success:function() {
                updateGlobalDelay();
                updateConfigForm();
                }
            })
        });
    });

    $(function() {
        $('#resetGlobalDelay').submit(function(event) {
            event.preventDefault(); 
            var form = $(this);
            $.ajax({
                type: form.attr('method'),
                url: form.attr('action'),
                success:function() {
                updateGlobalDelay();
                updateConfigForm();
                }
            })
        });
    });

    $(function () {
        $('#validateJson').submit(function(event) {
            event.preventDefault(); 
            var form = $(this);
            $.ajax({
                type: form.attr('method'),
                url: form.attr('action'),
                data: {"jsonReply":$('#textReply').val(), "jsonEditingPart":$('#FindEditingPart').val(), "replyType":$('#replyType').val()},
                success:function(data) {
                alert(data);
                }
            })
        });
    });


    $(function() {
        $('#resetFakeImages').submit(function(event) {
            event.preventDefault(); 
            var form = $(this);
            $.ajax({
                type: form.attr('method'),
                url: form.attr('action'),
                success:function() {
                    updateFakeImages();
                }
            })
        });
    });

    $(function() {
        $('#resetFakeFiles').submit(function(event) {
            event.preventDefault(); 
            var form = $(this);
            $.ajax({
                type: form.attr('method'),
                url: form.attr('action'),
                success:function() {
                    updateFakeFiles();
                }
            })
        });
    });

    $(function() {
        $("#setConfigFromTemplate").submit(function(event) {
            event.preventDefault(); 
            var form = $(this);
            $.ajax({
                type: form.attr('method'),
                url: form.attr('action'),
                data: {"filename":$("#template-select option:selected").text()},
                success:function() {
                    $('#modal').modal('hide');
                    updateConfigForm();
                    updateGlobalDelay();
                    updateServerAddress();
                }
            })
        });
    });

    $(function() {
        $("#delConfigFromTemplate").submit(function(event) {
            event.preventDefault(); 
            var form = $(this);
            $.ajax({
                type: form.attr('method'),
                url: form.attr('action'),
                data: {"filename":$("#template-select option:selected").text()},
                success:function() {
                    updateTextAreaInModal();
                }
            })
        });
    });

    $(function() {
        $('#setReply').submit(function(event) {
            event.preventDefault(); 
            var form = $(this);
            $.ajax({
                type: form.attr('method'),
                url: form.attr('action'),
                data: form.serialize(),
                success:function() {
                updateConfigForm();
                $('#requestTextArea').val("");
                $('#customDelayFrom').val("");
                $('#customDelayTo').val("");
                $('#httpCode').val("");
                $('#customContentType').val("");
                $('#FindEditingPart').val("");
                $('#textReply').val("");
                $('#submitApplyReply').attr('disabled', 'disabled');
                document.getElementById("accumulationDelay").checked = false;
                }
            })
        });
    });

    $(function() {
        $('#resetReply').submit(function(event) {
            event.preventDefault(); 
            var form = $(this);
            $.ajax({
                type: form.attr('method'),
                url: form.attr('action'),
                data: form.serialize(),
                success:function() {
                updateConfigForm();
                }
            })
        });
    });

    $(function() {
        $('#applyTextAreaConfig').submit(function(event) {
            event.preventDefault();
            var form = $(this);
            $.ajax({
                type: form.attr('method'),
                url: form.attr('action'),
                data: form.serialize(),
                success:function() {
                    document.getElementById('head').style.background = 'linear-gradient(45deg, #5fd7ff, #0f48bc)';
                    updateConfigForm();
                    updateGlobalDelay();
                    updateServerAddress();
                    $('#submitApplyTextAreaConfig').attr('disabled', 'disabled');
                }, 
                error: function(data) {
                    alert(data.responseText);
                    document.getElementById('head').style.background = 'linear-gradient(45deg, #B00000 , #F00000)';
                    $('#submitApplyTextAreaConfig').attr('disabled', 'disabled');
                }
            })
        });
    });

    $(function() {
        $('#saveAsTemplate').submit(function(event) {
            event.preventDefault(); 
            var form = $(this);
            $.ajax({
                type: form.attr('method'),
                url: form.attr('action'),
                data: {"filename":$('#setFileName').val()},
                success:function() {
                    $('#modal-save-template').modal('hide');
                }
            })
        });
    });
});

function updateTextAreaInModal() {
    var select = document.getElementById("template-select");
    select.innerHTML = "";
    $.ajax({
        type: 'POST',
        url: '/getConfigTemplates',
        success:function(data) {
            var objects = JSON.parse(data);
            for(index in objects) {
                select.options[select.options.length] = new Option(objects[index], index);
            }
        }
    })
};

function updateGlobalDelay() {
    $('#submitApplyGlobalDelay').attr('disabled', 'disabled');
    $.ajax({
        type: 'POST',
        url: '/getGlobalDelayFrom',
        success:function(data) {
            $('#globalDelayFrom').val(""); 
            $('#globalDelayFrom').attr("placeholder", data);
        }
    })
    $.ajax({
        type: 'POST',
        url: '/getGlobalDelayTo',
        success:function(data) {
            $('#globalDelayTo').val("");
            $('#globalDelayTo').attr("placeholder", data);
        }
    })
};

function updateServerAddress() {
    $.ajax({
        type: 'POST',
        url: '/getServerAddress',
        success:function(data) {
            $('#serverAddress').val("");
            $('#submitApplyServerAddress').attr('disabled', 'disabled');
            $('#serverAddress').attr("placeholder", data);
        }
    })
};

function updateFakeImages() {
    $.ajax({
        type: 'POST',
        url: '/getFakeImages',
        success:function(data) {
            $('#fakeImages').val(data);

        }
    })
};

function updateFakeFiles() {
    $.ajax({
        type: 'POST',
        url: '/getFakeFiles',
        success:function(data) {
            $('#fakeFiles').val(data);
        }
    })
};


    function updateConfigForm() {
        $.ajax({
            type: 'POST',
            url: '/getConfigJson',
            success:function(data) {
                $('#textareaConfigFile').val(data);
            }
        })
    };

    function updateSelectInModal(object) {
        var myobject = object;
        var select = document.getElementById("template-select");
        while (select.options.length) {
            select.remove(0);
        }
        for(index in myobject) {
            console.log(index)
            select.options[select.options.length] = new Option(myobject[index], index);
        }
    }
  
    function disableButton(obj, button) {
        var object = $(obj).val();
        if (object.length != 0) {
            $(button).removeAttr('disabled');
        } else {
            $(button).attr('disabled', 'disabled');
        }
    }

    function disableAccumulationDelayCheckBox() {
        var select = $('#replyType option:selected').text()
        if (select == 'Merge json' || select == 'Do not fake response' || select ==  'Delete json params') {
            document.getElementById("dontSendRequest").disabled = true;
            document.getElementById("dontSendRequest").checked = false;
        } else {
            document.getElementById("dontSendRequest").disabled = false;
        }
    }

    function disableFindEditingPart() {
        var select = $('#replyType option:selected').text()
        if (select == 'Merge json' || select ==  'Delete json params') {
            $('#FindEditingPart').show();
        } else {
            $('#FindEditingPart').hide();
            $('#FindEditingPart').val("");
        }
    }

    function monitorSelectReplyType() {
        disableFindEditingPart();
        disableAccumulationDelayCheckBox();
    }

    function disableButtonApplyDelay(from, to, button) {
        var from = $(from).val();
        var to = $(to).val();
        if (from.length != 0 || to.length != 0) {
            $(button).removeAttr('disabled');
        } else {
            $(button).attr('disabled', 'disabled');
        }
    }

    function checkDelayFrom(paramDelayFrom, paramDelayTo) {
        var delayFrom = $(paramDelayFrom).val();
        var delayTo = $(paramDelayTo).val();
        var delayToInt = parseInt(delayTo, 10);
        var delayFromInt = parseInt(delayFrom, 10);
        if (delayFrom.length != 0 && (delayToInt < delayFromInt || delayTo == '')) {
            $(paramDelayTo).val(delayFrom);
        }
    }

    function getNameFakeFile (str){
        if (str.lastIndexOf('\\')){
            var i = str.lastIndexOf('\\')+1;
        }
        else{
            var i = str.lastIndexOf('/')+1;
        }						
        var filename = str.slice(i);			
        var uploaded = document.getElementById("fakeFileLoad");
        uploaded.innerHTML = filename;
    } 
    
    function getNameLoadConfig (str){
        if (str.lastIndexOf('\\')){
            var i = str.lastIndexOf('\\')+1;
        }
        else{
            var i = str.lastIndexOf('/')+1;
        }						
        var filename = str.slice(i);			
        var uploaded = document.getElementById("loadConfigFile");
        uploaded.innerHTML = filename;
    }

    function getNameTemplateFile (str){
        if (str.lastIndexOf('\\')){
            var i = str.lastIndexOf('\\')+1;
        }
        else{
            var i = str.lastIndexOf('/')+1;
        }						
        var filename = str.slice(i);			
        var uploaded = document.getElementById("loadTemplateFile");
        uploaded.innerHTML = filename;
    } 

