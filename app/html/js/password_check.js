const checkPasswordDiff = (id0, id1, eid, sid, thisid) => {
    var e0 = document.getElementById(id0);
    var e1 = document.getElementById(id1);
    var e3 = document.getElementById(eid);
    var e4 = document.getElementById(sid);
    var e5 = document.getElementById(thisid);
    //console.log(e0,e1,e3,e4);
    e3.style.display = 'block';
    if(e0.value.length<8 || e1.value.length<8){
        e3.innerHTML = 'パスワードは8文字以上で入力してください';
        e4.disabled = true;   
        e5.style.background = '#ff6666';
        if(e0.value.length>7 && e1.value.length===0){
          e3.innerHTML = '確認用パスワードを入力してください';
          e0.style.background = 'white'
          e1.style.background = '#fff6666'
        }
        return false;     
    }else if(e0.value.length>32 || e1.value.length>32){
        e3.innerHTML = 'パスワードは32文字以内で入力してください';
        e4.disabled = true;   
        e5.style.background = '#ff6666';
        return false;    
    }else if(!(e0.value === e1.value)){
        e3.innerHTML = 'パスワードが一致していません';
        e1.style.background = '#ff6666';
        e4.disabled = true;
        return false;
    }
    e0.style.background = 'white';
    e1.style.background = 'white';
    e3.innerHTML = ''
    e3.style.display = 'none';
    e4.disabled = false;
    return true;
}

const addEventCheckPassDiff = () => {
    var p0 = document.getElementById('pass0');
    var p1 = document.getElementById('pass1');
    var e0 = document.getElementById('error0');
    e0.style.display = 'none';
    p0.addEventListener('keyup', ()=>{
      let res = checkPasswordDiff('pass0', 'pass1', 'error0', 'submit0', 'pass0');
     /*  let e0 = document.getElementById('pass0');
      let e1 = document.getElementById('pass1');
      console.log(!res);
      if(!res){
        e0.style.background = '#ff6666';
        e1.style.background = '#ff6666';
      }else{
        e0.style.background = 'white';
        e1.style.background = 'white';
      } */
    })

    p1.addEventListener('keyup', ()=>{
      let res = checkPasswordDiff('pass0', 'pass1', 'error0', 'submit0', 'pass1');
     /*  let e0 = document.getElementById('pass0');
      let e1 = document.getElementById('pass1');
      console.log(!res);
      if(!res){
        e0.style.background = '#ff6666';
        e1.style.background = '#ff6666';
      }else{
        e0.style.background = 'white';
        e1.style.background = 'white';
      } */
    })

}