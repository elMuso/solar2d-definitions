return {
    ---This are folders that are to not be included due to being mostly info nad not actual api
    excluded_folders = { "library_ads", "library_facebook", "library_event",
        "library_gameNetwork", "library_index", "library_lfs", "library_socket",
        "library_sqlite3", "type_Boolean", "type_CoronaClass",
        "type_Function", "type_Userdata", "type_Table", "type_String",
        "type_Scene", "type_RoundedRectPath", "type_Object" },
    --These libreares are not global and are required. This does a quick fix for that
    imported_libraries = {
        physics = true,
        composer = true,
        crypto = true,
        json = true,
        licensing = true,
        store = true,
        widget = true
    },
    --- This toggles argument docs generation
    generate_arguments_docs = true,
    generate_class_docs = true,
    -- For some reason the docs list single argument function as multiple arguments. This should fix that
    single_argument_functions = {
        ["widget.newSlider"] = "NewSliderOptions",
        ["widget.newProgressView"] = "NewProgressViewOptions",
        ["widget.newPickerWheel"] = "NewPickerWheelOptions",
        ["widget.newScrollView"] = "NewScrollViewOptions",
        ["widget.newSegmentedControl"] = "NewSegmentedControlOptions",
        ["display.newEmbossedText"] = "NewEmbossedTextOptions",
        ["widget.newTabBar"] = "NewTabBarOptions",
        ["display.newText"] = "NewTextOptions",
        ["display.newMesh"] = "NewMeshOptions"
    },
    -- To have nice autocompletion some manual work is required
    custom_overloads = {
        ["media.playVideo"] = {
            -- original "(path:string, baseSource:Constant?, showControls:boolean, listener:Listener?)",
            "(path:string, showControls:boolean, listener:Listener?)",
            "(path:string, showControls:boolean)",
        },
        ["graphics.newImageSheet"] = {
            -- original (filename:string, baseDir:Constant?, options:table)
            "(filename:string, options:table)"
        },
        ["native.showWebPopup"] = {
            -- original (x:number?, y:number?, width:number?, height:number?, url:string, options:table?)
            "(x:number, y:number, url:string, options:table?)",
            "(x:number, y:number, width:number?, height:number?, url:string, options:table?)",
            "(url:string, options:table?)",
            "(url:string)",

        },
        ["table.insert"] = {
            -- original (t:table, pos:number?, value:any)
            "(t:table, value:any)"
        },
        ["network.download"] = {
            -- original (url:string, method:string, listener:Listener, params:table?, filename:string, baseDirectory:Constant?)
            "(url:string, method:string, listener:Listener, filename:string, baseDirectory:Constant?)",
            "(url:string, method:string, listener:Listener, filename:string)"
        },
        ["GroupObject.insert"] = {
            -- original (index:number?, child:DisplayObject, resetTransform:boolean?)
            "(child:DisplayObject, resetTransform:boolean?)",
            "(child:DisplayObject)",
        },
        ["display.newRoundedRect"] = {
            -- original (parent:GroupObject?, x:number, y:number, width:number, height:number, cornerRadius:number)
            "(x:number, y:number, width:number, height:number, cornerRadius:number)"
        },
        ["display.newImage"] = {
            -- original1 (parent:GroupObject?, filename:string, baseDir:Constant?, x:number?, y:number?)
            -- original2 (parent:GroupObject?, imageSheet:ImageSheet, frameIndex:number, x:number?, y:number?)
            "(filename:string, baseDir:Constant?, x:number?, y:number?)",
            "(filename:string, x:number?, y:number?)",
            "(imageSheet:ImageSheet, frameIndex:number, x:number?, y:number?)",
            "(imageSheet:ImageSheet, frameIndex:number)"
        },
        ["network.upload"] = {
            -- original (url:string, method:string, listener:Listener, params:table?, filename:string, baseDirectory:Constant?, contentType:Constant?)
            "(url:string, method:string, listener:Listener, params:table?, filename:string, baseDirectory:Constant?)",
            "(url:string, method:string, listener:Listener, params:table?, filename:string)",
            "(url:string, method:string, listener:Listener, filename:string, baseDirectory:Constant?, contentType:Constant?)",
            "(url:string, method:string, listener:Listener, filename:string, baseDirectory:Constant?)",
            "(url:string, method:string, listener:Listener, filename:string)",
        },
        ["display.newSprite"] = {
            -- original (parent:GroupObject?, imageSheet:ImageSheet, sequenceData:table)
            "(imageSheet:ImageSheet, sequenceData:table)"
        },
        ["display.newSnapshot"] = {
            -- original (parent:GroupObject?, w:number, h:number)
            "(w:number, h:number)"
        },
        ["display.newPolygon"] = {
            -- original (parent:GroupObject?, x:number, y:number, vertices:Array)
            "(x:number, y:number, vertices:Array)"
        },
        ["display.newImageRect"] = {
            -- original (parent:GroupObject?,filename:string, baseDir:Constant?, width:number, height:number)
            -- original (parent:GroupObject?, imageSheet:ImageSheet, frameIndex:number, width:number, height:number)
            "(imageSheet:ImageSheet, frameIndex:number, width:number, height:number)",
            "(filename:string, baseDir:Constant?, width:number, height:number)",
            "(filename:string, width:number, height:number)"
        },
        ["display.newLine"] = {
            -- original (parent:GroupObject?, x1:number, y1:number,x2:number, y2:number, ...:number?)
            "(x1:number, y1:number,x2:number, y2:number, ...:number?)",
            "(x1:number, y1:number,x2:number, y2:number)"
        },
        ["display.newCircle"] = {
            -- original (parent:GroupObject?, xCenter:number, yCenter:number, radius:number)
            "(xCenter:number, yCenter:number, radius:number)"
        },
        ["display.newRect"] = {
            -- original (parent:GroupObject?,x:number, y:number, width:number, height:number)
            "(x:number, y:number, width:number, height:number)"
        },

        ["display.loadRemoteImage"] = {
            -- original (url:string, method:string, listener:Listener, params:table?, destFilename:string, baseDir:Constant?, x:number?, y:number?)
            "(url:string, method:string, listener:Listener, destFilename:string, baseDir:Constant?, x:number?, y:number?)",
            "(url:string, method:string, listener:Listener, destFilename:string, baseDir:Constant?,)"
        }
    }

}
