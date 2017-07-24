/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
  renderIcon: function(component) {
    var prefix = "slds-";
    var svgns = "http://www.w3.org/2000/svg";
    var xlinkns = "http://www.w3.org/1999/xlink";
    var size = component.get("v.size");
    var name = component.get("v.name");
    var classname = component.get("v.class");
    var containerclass = component.get("v.containerClass");
    var category = component.get("v.category");

    var containerClassName = [
        prefix+"icon_container",
        prefix+"icon-"+category+"-"+name,
        containerclass
        ].join(' ');
    component.set("v.containerClass", containerClassName);

    var svgroot = document.createElementNS(svgns, "svg");
    var iconClassName = prefix+"icon "+prefix+"icon--x-" + size+" "+classname;
    svgroot.setAttribute("aria-hidden", "true");
    svgroot.setAttribute("class", iconClassName);
    svgroot.setAttribute("name", name);

    // Add an "href" attribute (using the "xlink" namespace)
    var shape = document.createElementNS(svgns, "use");
    shape.setAttributeNS(xlinkns, "href", component.get("v.svgPath"));
    svgroot.appendChild(shape);

    var container = component.find("container").getElement();
    container.insertBefore(svgroot, container.firstChild);
  }
})