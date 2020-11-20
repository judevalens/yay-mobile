import 'package:flutter/material.dart';

class CustomButton extends PopupMenuButton{

}

class CustomButtonState extends PopupMenuButtonState{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    assert(debugCheckHasMaterialLocalizations(context));

    if (widget.child != null)
      return Tooltip(
        message: widget.tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
        child: InkWell(
          onTap: widget.enabled ? showButtonMenu : null,
          canRequestFocus: true,
          child: widget.child,
        ),
      );

    return IconButton(
      icon: widget.icon,
      padding: widget.padding,
      tooltip: widget.tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
      onPressed: widget.enabled ? showButtonMenu : null,
    );
  }
  }

