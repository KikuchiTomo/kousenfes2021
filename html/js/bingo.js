function bingoSquare(props, onClick){
    // params
    this.num = props.num;
    this.isOpen = props.isOpen;

    // render
    let sq_num = document.createElement('div');
    sq_num.innerHTML = (!this.isOpen) ? String(this.num) : "OPEN";
    sq_num.dataset.number = this.num;
    sq_num.dataset.isOpen = this.isOpen;
    sq_num.dataset.uniqId = this.id;
    sq_num.addEventListener('click', onClick);
    return sq_num;
}

function bingoSheet(BingoData){
    let bingo_sheet = document.createElement('table');    
    for(let y=0; y<5; y++){
        let row = document.createElement('tr');
        for(let x=0; x<5; x++){
            let sq  = document.createElement('td');
            let state = {
                num : BingoData.num[y][x],
                isOpen : BingoData.isOpen[y][x],
            };
            sq.appendChild(bingoSquare(state, function(){console.log("Click!")}));
            row.appendChild(sq);
        }
        bingo_sheet.appendChild(row);
    }
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

async function execBingo(config){
    this.id = config.id || "none"    
    bingo_data = await getBingoDataFromServer();
    console.log(bingo_data)
    console.log(bingo_data.bingo_id)    

    if(bingo_data===null){
        console.log("Error");
    }else{
        let bingo_elem = bingoSheet(bingo_data);
        let bingo_container = document.getElementById(this.id);        
        bingo_container.appendChild(bingo_elem); // create Bingo
    }
}