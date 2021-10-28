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
        g3.disabled = false;
        g4.disabled = false;
        g5.disabled = false;
    }else if(idx==2){
        // 専攻科
        e1.disabled = false;
        e2.disabled = true;
        g3.disabled = true;
        g4.disabled = true;
        g5.disabled = true;
        g3.style.display = 'none';
        g4.style.display = 'none';
        g5.style.display = 'none';
    }else if(idx==3){
        // 中学生
        e1.disabled = false;
        e2.disabled = true;
        g4.style.display = 'none';
        g5.style.display = 'none';
        g4.disabled = true;
        g5.disabled = true        ;
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

const checkGradeShowHidden = () => {
    var sel0 = document.getElementById('select-course');
    var sel1 = document.getElementById('select-class');
    var idx = document.getElementById('select-grade').selectedIndex;
    if(idx==1){
        sel0.style.display = 'none';
        sel0.disabled = true;
        sel1.style.display = 'inline';
        sel1.disabled = false;
    }else{
        sel0.style.display = 'inline';
        sel0.disabled = false;
        sel1.style.display = 'none';
        sel1.disabled = true;
    }
}

const switchGradeSelects = (sel ,is_show) => {
    var grade12345 = document.getElementById('grade-12345');
    var grade123   = document.getElementById('grade-123');
    var grade12    = document.getElementById('grade-12');
   console.log(grade12345, grade123, grade12);

    // 表示を切り替え
    if(sel==0){        
        grade12345.style.display = 'inline';
        grade123.style.display   = 'none';
        grade12.style.display    = 'none';
        grade12345.disabled      = false;
        grade123.disabled        = true;
        grade12.disabled         = true;
    }else if(sel==1){
        grade12345.style.display = 'none';
        grade123.style.display   = 'inline';
        grade12.style.display    = 'none'; 
        grade12345.disabled      = true;
        grade123.disabled        = false;
        grade12.disabled         = true;
    }else{
        grade12345.style.display = 'none';
        grade123.style.display   = 'none';
        grade12.style.display    = 'inline'; 
        grade12345.disabled      = true;
        grade123.disabled        = true;
        grade12.disabled         = false;
    }

     // 有効無効
     if(!is_show){
        grade12345.disabled = !is_show;
        grade123.disabled   = !is_show;
        grade12.disabled    = !is_show;
    }
}

const switchCourseSelects = (sel, is_show) => {
    var course0 = document.getElementById('select-course');
    var class0  = document.getElementById('select-class');

    if(sel==0){
        course0.style.display = 'inline';
        class0.style.display  = 'none';
        course0.disabled = false;
        class0.disabled = true;
    }else{
        course0.style.display = 'none';
        class0.style.display  = 'inline';
        course0.disabled = true;
        class0.disabled = false;
    }

    if(!is_show){
        course0.disabled = !is_show;
        class0.disabled  = !is_show;
    }   
}

const controlSelect = () => {
    // 選択肢を動的に変えるのは，種別と学年の選択時のみ    
    var cates = document.getElementById('select-cate');
    
    var cate =  cates.selectedIndex; // 選択中のインデックス
    if(cate===1){ // 本科
        switchGradeSelects(0,  true); // 1~5を表示
        var grade = document.getElementById('grade-12345').selectedIndex;
        if(grade===1){ // 一年を選択時
            switchCourseSelects(1, true); // クラスを表示
        }else{
            switchCourseSelects(0, true); // コースを表示
        }
    }else if(cate===2){ // 専攻科
        switchGradeSelects(2,  true); // 1~2を表示
        switchCourseSelects(0, false); // 非表示
    }else if(cate===3){ // その他
        switchCourseSelects(0, false); // 非表示
        switchGradeSelects(0,  false); // 非表示
    }else{
        switchCourseSelects(0, false); // 非表示
        switchGradeSelects(0,  false); // 非表示
    }
    console.log("Hello");
}

const setInitSelect = () => {
    document.getElementById('select-cate').selectedIndex = 0;
    document.getElementById('select-course').selectedIndex = 0;
    document.getElementById('select-class').selectedIndex = 0;
    document.getElementById('grade-12345').selectedIndex = 0;
    document.getElementById('grade-123').selectedIndex = 0;
    document.getElementById('grade-12').selectedIndex = 0;
}