/**
 * Created by Kikuchi Tomoo
 * © 2021 Kikuchi Tomoo. All Rights Reserved
 */

class ajaxImageController{
    constructor(config) {      
        this.ajax_   = 'true';
        this.method_ = 'POST';
        this.url_    = 'https://www.kousensai.jp/kousenadmin/common/update/add/img';
        this.src_    = 'https://www.kousensai.jp/kouhou_images/';
        this.input_  = config.img_input
        this.area_   = config.view_area 
        this.prog_   = config.prog_area 
        this.src_input_ = config.img_src_input 
        this.file_;
        this.fpath_;
        
        var input_elem   = document.getElementById(this.input_);
        var preview_elem = document.getElementById(this.area_);
        
        var this0 = this;

        function event(e){
            this0.file_ = e.target.files;
            let file_type = this0.file_[0].type
            console.log(file_type);

            if(file_type.split("/")[0].match(/image/)==null){
                alert("画像のみ受け付けられます。\n MIME TYPE: image/xxとなるファイルを選択してください。");
                return;
            }
            
            this0.sendData();
            this0.viewData();
        }

        input_elem.addEventListener('change', event ,false)
    }

    sendData(){
        var fd = new FormData();
        fd.append('file', this.file_[0]);

        var req = new XMLHttpRequest();
        var bar = document.getElementById(this.prog_);
        bar.style.width = '0%';
        
        req.upload.addEventListener('progress', function progressbar(e){
            //プログレスバーの処理をここに書く
            var percent = Math.round(e.loaded / e.total * 100);
            bar.style.width =  String(percent) + '%';
            console.log('progress', percent);
        });

        var this0 = this;
        var area = this.area_;
        var src_input = this.src_input_;
        req.onreadystatechange = function(){
            if(req.readyState==4 && req.status==200){
                console.log( req.responseText);
                var fpath = req.responseText;
                
                // var img_elem = document.getElementById('preview-img');
                // var pic_elem = document.getElementById('img-pics');
                console.log(area)
                var img_elem = document.getElementById(area);
                var pic_elem = document.getElementById(src_input);

                console.log(img_elem);
                img_elem.src   = fpath;
                pic_elem.value = fpath;
            }else{
                console.log('Failed. HttpStatus:' + req.statusText);
            }
        };
    
        // let token = document.getElementById("csrf-token")

        req.open(this.method_, this.url_, true);
        // req.setRequestHeader('X-CSRF-Token', token.value)   
        req.send(fd);
    }

    viewData(){
        var rd = new FileReader();
        rd.readAsDataURL(this.file_[0]);

        rd.onerror = function(){
            alert('ファイル読み込みに失敗しました');
        }

        var this_area_ = this.area_;
        var this_src_  = this.src_;
        rd.onload = function(e) {

            while (this_area_.firstChild) this_area_.removeChild(this_area_.firstChild);
            
            var imgtag = document.createElement('img');
            // imgtag.id  = 'preview-img';
            imgtag.id = this_area_;
            // imgtag.src = "https://kousenfes.tokyo/images/" + e.target.result;
            imgtag.src = this_src_ + e.target.result;
            document.getElementById(this_area_).appendChild(imgtag);
        }

    }
}
