function bingoSquare(props) {
    // params
    this.num = props.num;
    this.isOpen = props.isOpen;
    this.where = props.whr;

    // render
    let sq_num = document.createElement('div');
    sq_num.innerHTML = (this.isOpen === 0) ? String(this.num) : "★";
    if (this.num === 0) sq_num.innerHTML = (this.isOpen === 0) ? "S" : "★"; // 真ん中はS    
    sq_num.id = this.where;
    sq_num.dataset.number = this.num;
    sq_num.dataset.isOpen = this.isOpen;
    sq_num.dataset.uniqId = this.id;
    return sq_num;
}

function bingoSheet(BingoData) {
    let bingo_sheet = document.createElement('table');
    let count = 0;
    for (let y = 0; y < 5; y++) {
        let row = document.createElement('tr');
        for (let x = 0; x < 5; x++) {
            let sq = document.createElement('td');
            let state = {
                num: BingoData.num[x][y],
                isOpen: BingoData.isOpen[x][y],
                whr: count
            };
            count = count + 1;
            sq.appendChild(bingoSquare(state))
            row.appendChild(sq);
        }
        bingo_sheet.appendChild(row);
    }
    return bingo_sheet;
}

function createArray(x, y, value) {
    // 多次元配列の宣言
    var ary = []
    for (let i = 0; i < y; i++) {
        ary[i] = []
        for (let j = 0; j < x; j++) {
            ary[i][j] = value
        }
    }
    return ary
}

function drawBingoFromServer(config) {
    var bingo_view = config.id || "none"
    let urlList = [
        "https://www.kousensai.jp/bingo/play",
        "https://www.kousensai.jp/bingo/numbers"
    ];
    Promise.all(
        urlList.map(
            url => fetch(url).then((response) => {
                if (!response.ok) {
                    throw new Error(`HTTP error ${response.status}`);
                }
                return response.json();
            })
        )
    )
        .then((jsonBaseList) => {
            // 成功時
            bingo_user = jsonBaseList[0] // ユーザのビンゴデータ
            bingo_info = jsonBaseList[1] // ユーザのビンゴ情報
            console.log("JSONS => ", jsonBaseList);

            // ビンゴカード表示用の内部配列を用意
            var bingo_data = {};
            bingo_data.num = bingo_user.num // ビンゴの内容をコピー
            bingo_data.isOpen = createArray(5, 5, 0); // 5x5の配列を0で初期化

            // 空いた番号のマスク配列を作る
            if (bingo_user && bingo_info) {
                let status = bingo_info.status;


                for (let i = 0; i < 5; i++) {
                    for (let j = 0; j < 5; j++) {
                        let crrent_num = bingo_data.num[i][j];
                        let is_open_num = 0;
                        if (bingo_info.is_open.indexOf(crrent_num) === -1) is_open_num = 0;  // 現在の番号が空いてるリストにない
                        else is_open_num = 1;  // ある

                        bingo_data.isOpen[i][j] = is_open_num; // bingo_dataに反映
                    }
                }

                // ビンゴカードの生成 & 表示
                let bingo_elem = bingoSheet(bingo_data);
                let bingo_container = document.getElementById(bingo_view);
                bingo_container.innerHTML = ""; // Viewをクリア
                bingo_container.appendChild(bingo_elem); // 再描画
                if (status === -2) alert("ビンゴ!おめでとうございます！");

                // 描画してからメッセージ表示
                // if(status>0) alert(String(status) + "リーチ！おしい！");  => うぜぇ
            } else {
                alert("ビンゴデータが破損しています");
            }
        })
        .catch((error) => {
            // エラーハンドリング
            alert("ビンゴデータの取得に失敗しました");
            console.log("HTTP ERROR: ", error)
        });
}