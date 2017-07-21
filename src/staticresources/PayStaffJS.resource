/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

function singleSelectCheckBoxStatus(clickedCheckBox) {
    var currentFlag = clickedCheckBox.checked;
    if (currentFlag) {
        var receivedInputID = 'inputId';
        var inputCheckBox = document.getElementsByTagName("input");
        for (var i = 0; i < inputCheckBox.length; i++) {
            if (inputCheckBox[i].id.indexOf(receivedInputID) != -1) {
                inputCheckBox[i].checked = !currentFlag;
            }
        }
        clickedCheckBox.checked = currentFlag;
    }
}


function selectAllCheckboxes(obj, receivedInputID) {
    var inputCheckBox = document.getElementsByTagName("input");
    for (var i = 0; i < inputCheckBox.length; i++) {
        if (inputCheckBox[i].id.indexOf(receivedInputID) != -1) {
            inputCheckBox[i].checked = obj.checked;
        }
    }
}

function checkBoxStatus() {
    var receivedInputID = 'inputId';
    var allSelected = true;
    var obj = document.getElementsByClassName("selectAllCBK")[0];
    var inputCheckBox = document.getElementsByTagName("input");
    for (var i = 0; i < inputCheckBox.length; i++) {
        if (inputCheckBox[i].id.indexOf(receivedInputID) != -1) {
            if (!inputCheckBox[i].checked) {
                allSelected = false;
            }
        }
    }
    obj.checked = allSelected;
}

function selectListChanged(src, trg) {
    document.getElementById(trg).value = document.getElementById(src).value;
}

function startAjaxLoader(eleId) {
    document.getElementById(eleId).style.display = "";
}

function stopAjaxLoader(eleId) {
    document.getElementById(eleId).style.display = "none";
}