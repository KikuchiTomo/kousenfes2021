/*
  Scroll change color class
  Created by Kikuchi Tomoo (2021 - 07 - 24)
  Copyright © 2021 Kikuchi Tomoo. All rights reserved.
*/

class scrollChangeClass{
    constructor(config){
        console.log(config)
        this.scroll_target_id = config.observe_target_id
        this.color_target_ids = config.color_target_ids
        this.trigger_target_id = config.trigger_target_id
        this.class_name = config.class_name
        console.log(this)
        
        this.scroll_elem  = document.getElementById(this.scroll_target_id)
        this.trigger_elem = document.getElementById(this.trigger_target_id)
        this.target_elems = []
        this.target_num   = this.color_target_ids.length
        for(let i=0; i<this.target_num; i++){
            this.target_elems[i] = document.getElementById(this.color_target_ids[i])
        }
        
    }

    proc(){
        this.trigger_val = this.trigger_elem.clientHeight - 100        
        this.scroll_elem = document.getElementById(this.scroll_target_id)        
        this.scroll_val = this.scroll_elem.scrollTop + 100// get Scroll
        
        if(this.scroll_val > this.trigger_val){
            this.addTargetClassName(this.class_name)
        }else{
            this.removeTargetClassName(this.class_name)
        }
    }

    addTargetClassName(class_name){
        for(let i=0; i<this.target_num; i++){
            this.target_elems[i].classList.add(class_name)
        }
    }

    removeTargetClassName(class_name){
        for(let i=0; i<this.target_num; i++){
            this.target_elems[i].classList.remove(class_name)
        }
    }
}
