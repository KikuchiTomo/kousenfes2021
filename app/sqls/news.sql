create table kouhou.news (
       id                 int  auto_increment not null,
       title              varchar(60)         not null,
       description        text                not null,
       detail_title       text                not null,
       detail_desc        text                not null,
       notify_datetime    datetime            not null,
       image_path         text                not null,
       ena_flg            int                 not null default 1,
       del_flg            int                 not null default 0,
       reg_time           timestamp           not null default current_timestamp,
       upd_time           timestamp           not null default current_timestamp on update current_timestamp,
       primary key(id)
 );

# example
# insert into news (title,description,detail_title,detail_desc,notify_datetime,image_path) values ("高専祭サイト開設", "サイトに関するお知らせです", "あああ","あああ", "2021-10-19", "NOIMAGE");