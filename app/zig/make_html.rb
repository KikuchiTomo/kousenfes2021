html = ''            
for i in 0..14       
html +=         "<tr>\n"\
                    +"<td><a href=\"/kousenadmin/bingo/lottery?num=#{i+1}\">#{i+1}</a></td>\n"\
                    +"<td><a href=\"/kousenadmin/bingo/lottery?num=#{i+16}\">#{i+16}</a></td>\n"\
                    +"<td><a href=\"/kousenadmin/bingo/lottery?num=#{i+31}\">#{i+31}</a></td>\n"\
                    +"<td><a href=\"/kousenadmin/bingo/lottery?num=#{i+46}\">#{i+46}</a></td>\n"\
                    +"<td><a href=\"/kousenadmin/bingo/lottery?num=#{i+61}\">#{i+61}</a></td>\n"\
                +"</tr>\n"
end

puts html