const selectCheck = () => {
    var e0 = document.getElementById('select-cate');
    var e1 = document.getElementById('select-grade');
    var e2 = document.getElementById('select-course');

    var g3 = document.getElementById('grade-3');
    var g4 = document.getElementById('grade-4');
    var g5 = document.getElementById('grade-5');

    var s0 = document.getElementById('school-name');

    var idx = e0.selectedIndex;
    e1.selectedIndex = 0;
    e2.selectedIndex = 0;
    s0.disabled = true;
    if(idx==0){
        // not selected
        e1.disabled = true;
        e2.disabled = true;
    }else if(idx==1){
        // 本科
        e1.disabled = false;
        e2.disabled = false;
        g3.style.display = 'inline';
        g4.style.display = 'inline';
        g5.style.display = 'inline';   
        g3.disabled = true;
        g4.disabled = true;
        g5.disabled = true;
    }else if(idx==2){
        // 専攻科
        e1.disabled = false;
        e2.disabled = true;
        g3.disabled = false;
        g4.disabled = false;
        g5.disabled = false;
        g3.style.display = 'none';
        g4.style.display = 'none';
        g5.style.display = 'none';
    }else if(idx==3){
        // 中学生
        e1.disabled = false;
        e2.disabled = true;
        g4.style.display = 'none';
        g5.style.display = 'none';
        g4.disabled = false;
        g5.disabled = false;
        s0.disabled = false;
    }else{
        // 保護者・その他
        e1.disabled = true;
        e2.disabled = true;
    }
}

const selectCheckSafariSub = () => {
    var e0 = document.getElementById('select-cate');
    var e1 = document.getElementById('select-grade');
    var e2 = document.getElementById('select-course');

    var g3 = document.getElementById('grade-3');
    var g4 = document.getElementById('grade-4');
    var g5 = document.getElementById('grade-5');

    var s0 = document.getElementById('school-name');

    var idx = e0.selectedIndex;
    e1.selectedIndex = 0;
    e2.selectedIndex = 0;
    s0.disabled = true;
   
    if(idx==0){
        // not selected
        e1.disabled = true;
        e2.disabled = true;
    }else if(idx==1){
        // 本科
        // ダメポイント：全て直がき
        e1.disabled = false;
        e2.disabled = false;  
        var p = document.getElementById('grade-2').parentNode;
        var c = p.children;
        var l = c.length
        for(let i=0; i<6; i++){
            if(c[i].tagName==='SPAN'||c[i].tagName==='span'){
                console.log(true)
                var ccopy = c[i].children[0].cloneNode(true);
                console.log(ccopy.id)
                c[i].after(ccopy); // insert
                console.log("ccp", ccopy)
                p.removeChild(c[i]); // delete
            }
        }   
        console.log("hon:", document.getElementById('grade-2').parentNode.children.length)          
    }else if(idx==2){
        // 専攻科
        e1.disabled = false;
        e2.disabled = true;
        
        // ダメすぎ↓
        var g3copy = g3.cloneNode(true);
        var g4copy = g4.cloneNode(true);;
        var g5copy = g5.cloneNode(true);;
        var cp=[g3copy, g4copy, g5copy];
        var p =g3.parentNode;
        var ch=g3.parentNode.children;
        var len=ch.length
        for(let i=3; i<6; i++){
            var c = ch[i].cloneNode(true);
            var n = document.createElement('span');
            n.id = "grade-" + String(i) + "s";
            n.style.display = 'none';
            n.appendChild(c);
            ch[i].after(n);
            p.removeChild(ch[i]);
        }
        console.log("sen:", document.getElementById('grade-2').parentNode.children.length)
    }else if(idx==3){
        // 中学生
        e1.disabled = false;
        e2.disabled = true;
        s0.disabled = false;
        
        var p = document.getElementById('grade-2').parentNode;
        var c = p.children;
        var l = c.length
        console.log(l,c)
        var cnt = 0
        for(let i=0; i<l; i++){
            cnt+=1
            if(c[i].tagName==='SPAN'||c[i].tagName==='span'){
                //console.log(true)
                var ccopy = c[i].children[0].cloneNode(true);
                console.log(ccopy.id)
                c[i].after(ccopy); // insert
                console.log("ccp", ccopy)
                p.removeChild(c[i]); // delete
            }
        }    
        console.log("tyu:", document.getElementById('grade-2').parentNode.children.length,cnt)
        
         // ダメすぎ↓
         var g4copy = g4.cloneNode(true);
         var g5copy = g5.cloneNode(true);
         var cp=[g4copy, g5copy];
         var p =g4.parentNode;
         var ch=g4.parentNode.children;
         var len=ch.length
         for(let i=4; i<6; i++){
            var c = ch[i].cloneNode(true);
            var n = document.createElement('span');
            n.id = "grade-" + String(i) + "s";
            n.style.display = 'none';
            n.appendChild(c);
            ch[i].after(n);
            p.removeChild(ch[i]);
         }
         console.log("tyu:", document.getElementById('grade-2').parentNode.children.length)
    }else{
        // 保護者・その他
        e1.disabled = true;
        e2.disabled = true;
    }
}

// だめコード
// ダメすぎる
// Safariの仕様で動かないので，Safariだけ処理かえる
const selectCheckSafari = () => {
    var e0 = document.getElementById('select-cate');
    var e1 = document.getElementById('select-grade');
    var e2 = document.getElementById('select-course');

    var g3 = document.getElementById('grade-3');
    var g4 = document.getElementById('grade-4');
    var g5 = document.getElementById('grade-5');

    var s0 = document.getElementById('school-name');

    var idx = e0.selectedIndex;
    e1.selectedIndex = 0;
    e2.selectedIndex = 0;
    s0.disabled = true;
   
    if(idx==0){
        // not selected
        e1.disabled = true;
        e2.disabled = true;
    }else if(idx==1){
        // 本科
        // ダメポイント：全て直がき
        e1.disabled = false;
        e2.disabled = false;  
        var p = document.getElementById('grade-2').parentNode;
        var c = p.children;
        var l = c.length
        for(let i=0; i<6; i++){
            if(c[i].tagName==='SPAN'||c[i].tagName==='span'){
                console.log(true)
                var ccopy = c[i].children[0].cloneNode(true);
                console.log(ccopy.id)
                c[i].after(ccopy); // insert
                console.log("ccp", ccopy)
                p.removeChild(c[i]); // delete
            }
        }   
        selectCheckSafariSub()
        console.log("hon:", document.getElementById('grade-2').parentNode.children.length)          
    }else if(idx==2){
        // 専攻科
        e1.disabled = false;
        e2.disabled = true;
        
        // ダメすぎ↓
        var g3copy = g3.cloneNode(true);
        var g4copy = g4.cloneNode(true);;
        var g5copy = g5.cloneNode(true);;
        var cp=[g3copy, g4copy, g5copy];
        var p =g3.parentNode;
        var ch=g3.parentNode.children;
        var len=ch.length
        for(let i=3; i<6; i++){
            var c = ch[i].cloneNode(true);
            var n = document.createElement('span');
            n.id = "grade-" + String(i) + "s";
            n.style.display = 'none';
            n.appendChild(c);
            ch[i].after(n);
            p.removeChild(ch[i]);
        }
        console.log("sen:", document.getElementById('grade-2').parentNode.children.length)
    }else if(idx==3){
        // 中学生
        e1.disabled = false;
        e2.disabled = true;
        s0.disabled = false;
        
        /* var p = document.getElementById('grade-2').parentNode;
        var c = p.children;
        var l = c.length
        console.log(l,c)
        var cnt = 0
        for(let i=0; i<l; i++){
            cnt+=1
            if(c[i].tagName==='SPAN'||c[i].tagName==='span'){
                //console.log(true)
                var ccopy = c[i].children[0].cloneNode(true);
                console.log(ccopy.id)
                c[i].after(ccopy); // insert
                console.log("ccp", ccopy)
                p.removeChild(c[i]); // delete
            }
        }    
        console.log("tyu:", document.getElementById('grade-2').parentNode.children.length,cnt) */
        
        e0.selectedIndex = 1;
        selectCheckSafariSub();
        e0.selectedIndex = 3;

         // ダメすぎ↓
         var g4copy = g4.cloneNode(true);
         var g5copy = g5.cloneNode(true);
         var cp=[g4copy, g5copy];
         var p =g4.parentNode;
         var ch=g4.parentNode.children;
         var len=ch.length
         for(let i=4; i<len; i++){
            var c = ch[i].cloneNode(true);
            var n = document.createElement('span');
            n.id = "grade-" + String(i) + "s";
            n.style.display = 'none';
            n.appendChild(c);
            ch[i].after(n);
            p.removeChild(ch[i]);
         }
         console.log("tyu:", document.getElementById('grade-2').parentNode.children.length)
    }else{
        // 保護者・その他
        e1.disabled = true;
        e2.disabled = true;
    }
}