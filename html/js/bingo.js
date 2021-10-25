async function isopen(){
    let response = await fetch("");
    if(response.ok){
        let json_click = await response.json();
        return json_click
    }
    else{
        console.log("HTTP-Error: " + response.status);
        alert("通信に失敗しました ERROR: " + response.status);
        return null;
    }
}

async function click(props){
    console.log(props.num)
    console.log(props.whr)
    let table =document.getElementById("bingo-container")
    console.log(table)
    let elm = document.getElementById(props.whr)
    console.log(elm)
//    bingo_click = await isopen()    
    bingo_click = {"bingo_id":"001","status":"1","isOpen":[[3],[2],[50]]}
    flag = 0
    for(let i =0 ; i<bingo_click.isOpen.length ; i++){
        if(JSON.stringify(props.num)==JSON.stringify(bingo_click.isOpen[i])){
            flag = 1
        }
    }
    console.log(flag)
    if(flag==1){
        elm.dataset.isOpen = 0
    }
    console.log(elm.dataset.isOpen)
    elm.innerHTML= (elm.dataset.isOpen==1)? String(props.num) :"OP";
    return  
}

function bingoSquare(props, onClick){
    // params
    this.num = props.num;
    this.isOpen = props.isOpen;
    this.where =props.whr;

    // render
    let sq_num = document.createElement('div');
    sq_num.innerHTML = (this.isOpen==1) ? String(this.num) : "OP";
    sq_num.id= this.where;
    sq_num.dataset.number = this.num;
    sq_num.dataset.isOpen = this.isOpen;
    sq_num.dataset.uniqId = this.id;
    sq_num.addEventListener('click',onClick);
    return sq_num;
}

function bingoSheet(BingoData){
    let bingo_sheet = document.createElement('table');
    let count=0;    
    for(let y=0; y<5; y++){
        let row = document.createElement('tr');
        for(let x=0; x<5; x++){
            let sq  = document.createElement('td');
            let state = {
                num : BingoData.num[y][x],
                isOpen : BingoData.isOpen[y][x],
                whr :count
            };
            count=count+1;
            sq.appendChild(bingoSquare(state,function(){console.log("click");click(state)}));
            row.appendChild(sq);
        }
        bingo_sheet.appendChild(row);
    }
//    console.log(bingo_sheet)
    return bingo_sheet;
}

async function getBingoDataFromServer(){
    let response = await fetch('https://kousenfes.tokyo/bingo_data_get');
    if (response.ok) { // HTTP ステータスが 200-299 の場合
        // レスポンスの本文を取得(後述)
        let json = await response.json();
        return json;
      } else {
        console.log("HTTP-Error: " + response.status);
        alert("通信に失敗しました ERROR: " + response.status);
        return null;
      }
}

async function execBingo(config){       //最初に呼び出す関数
    this.id = config.id || "none"
    bingo_data={"bingo_id":"001","num":[[[1],[2],[50],[3],[4]],[[5],[6],[7],[8],[9]],[[10],[11],[12],[13],[14]],[[15],[16],[17],[18],[19]],[[20],[21],[22],[23],[24]]],"isOpen":[[[1],[1],[0],[0],[0]],[[0],[0],[0],[0],[0]],[[0],[0],[0],[0],[0]],[[0],[0],[0],[0],[0]],[[0],[0],[0],[0],[0]]]}     //kari
//    bingo_data = await getBingoDataFromServer();
    console.log(bingo_data)
    console.log(bingo_data.bingo_id)    

    if(bingo_data===null){
        console.log("Error");
    }else{
        let bingo_elem = bingoSheet(bingo_data);
        let bingo_container = document.getElementById(this.id);        
        bingo_container.appendChild(bingo_elem); // create Bingo
        console.log(bingo_container)
    }
}