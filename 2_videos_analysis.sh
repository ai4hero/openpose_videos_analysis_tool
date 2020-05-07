#!/bin/sh
# videos analysis
# 本脚本针对输入视频目录的所有文件进行批量分析。首先从/home/nano001/videos_input/遍历并分析里面所有待处理视频文件，以每一个文件的文件名为标识，分别计算视频json坐标，以待分析视频文件名为标识作为输出文件夹，存储到/home/nano001/project/pyc/opt/net_resolution/，每个分析后的视频文件到/home/nano001/project/openpose/videos_output/$date.mp4。而后，由tools文件夹的工具data2csv，对该视频文件分析后的数据文件夹进行数据处理，转换成csv格式，输出的csv数据包以日期+视频名为标识存储到/home/nano001/tools/data2csv/CSV_Output/。通过桌面的“分析结果”文件夹即可查看上传的这一批文件分别对应的json坐标和骨骼视频。每分析一个视频，清空/home/nano001/project/pyc/opt/net_resolution/文件夹。

# 进入openpose目录：
cd ~/project/openpose
echo "--------------------Welcome------------------------------"
echo "╱╱　╱   ',' ',' ',' ','☆　╱★　╱╱　╱   ',' ',' ',' ','☆　╱★　╱╱　╱"
echo "【正在启动步态识别视频分析系统.............................】"
echo "╱╱　╱   ',' ',' ',' ','☆　╱★　╱╱　╱   ',' ',' ',' ','☆　╱★　╱╱　╱"
echo "--------------------------------------------------------"

# 产生一个随机数
#ran=`tr -cd 'a-z' </dev/urandom | head -c 8`
date=`date +"%Y%m%d%H%M%S"`

ls ./videos_input > ~/tools/data2csv/temp/videos_input_list

for i in `cat ~/tools/data2csv/temp/videos_input_list`;
do
echo "正在对$i视频进行身体关键点坐标计算与生成骨骼视频..............."
#赋值视频文件路径
filename=./videos_input/$i

# 获取视频每秒帧数
ffmpeg -i $filename 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p" > ~/tools/data2csv/temp/frame_num
fr_num=`cat ~/tools/data2csv/temp/frame_num`
#获取视频时长
ffmpeg -i $filename 2>&1 | grep 'Duration' | cut -d ' ' -f 4 | sed s/,// > ~/tools/data2csv/temp/video_long
vi_long=`cat ~/tools/data2csv/temp/video_long`

# 启动openpose视频分析
./build/examples/openpose/openpose.bin --video videos_input/$i --net_resolution 256x192 --write_json net_resolution/json_$i_$date --write_video videos_output/out001-$i-$date.mp4
echo "正在对$i视频数据转换为CSV格式..............."
mkdir ~/tools/data2csv/CSV_Output/$i
# 打印文件路径
echo 文件来源：|tr '\n' ' ' >> ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv
echo 视频文件 >> ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv
echo 文件路径：|tr '\n' ' ' >> ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv
echo $filename >> ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv
echo 视频帧数 >> ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv
echo $fr_num >> ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv
echo 视频时长 >> ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv
echo $vi_long >> ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv
#获取视频总帧数
datapath=./net_resolution/json_$i_$date
ls -l $datapath | grep "^-" | wc -l > ~/tools/data2csv/temp/frames_all_num
fr_all=`cat ~/tools/data2csv/temp/frames_all_num`
#echo "请输入待测试者编号并启动步态分析系统(支持英文字母和数字，例如：ML6001)："
#read name_id
#获取openpose输出文件夹文件名列表
ls ./net_resolution/json_$i_$date > ~/tools/data2csv/temp/data_file_list
  for j in `cat ~/tools/data2csv/temp/data_file_list`;
  do
  cat net_resolution/json_$i_$date/$j > ~/tools/data2csv/temp/frame_data
  awk -F '"pose_keypoints_2d":\['  '{print $2}' ~/tools/data2csv/temp/frame_data |awk -F '\],"face_keypoints_2d"' '{print $1}' > ~/tools/data2csv/temp/body_data
  echo "进行中(正在理$i视频的第$j帧文件,总计$fr_all帧)....."
  echo "frame_ID,points_ID,x,y,c" >> ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv
    for k in `seq 0 3 72`;
    do
    echo $j > ~/tools/data2csv/temp/frame_id
    awk -F '_' '{print $2}' ~/tools/data2csv/temp/frame_id > ~/tools/data2csv/temp/frame_num
    cat ~/tools/data2csv/temp/frame_num|tr '\n' ' '  >> ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv
    echo ","|tr '\n' ' '  >> ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv
    point_id=$(expr $k / 3)
    echo "point_ID-$point_id"|tr '\n' ' '  >> ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv
    echo ","|tr '\n' ' '  >> ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv

    val=$(expr $k + 1)
# echo $val
    awk -F ',' '{print $'$val'}' ~/tools/data2csv/temp/body_data|tr '\n' ' '  >> ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv
    echo ","|tr '\n' ' '  >> ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv

    val=$(expr $k + 2)
#  echo $val
    awk -F ',' '{print $'$val'}' ~/tools/data2csv/temp/body_data|tr '\n' ' '  >> ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv
    echo ","|tr '\n' ' ' >> ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv

#可信度 
    val=$(expr $k + 3)
#  echo $val
    awk -F ',' '{print $'$val'}' ~/tools/data2csv/temp/body_data  >> ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv

    done
  done
  #一次实验中，body某个点的时序csv数据，一次数据处理得到25个点的25个文件。
  for j in `seq 0 24`;
  do
  grep -w "point_ID-$j" ~/tools/data2csv/CSV_Output/$i/csv_video_frames_$i.csv >> ~/tools/data2csv/CSV_Output/$i/$i-point-$j.csv

  done


  echo "完成对$i视频进行身体关键点坐标计算与生成骨骼视频！"
## 清空net_resolution
  rm -rf ./net_resolution/*

done



## 计算结果视频文件./videos_output/out001.mp4桌面“分析结果”文件夹

echo "--------------------Done！-----$date------------------------"
echo "╱╱　╱   ',' ',' ',' ','☆　╱★　╱╱　╱   ',' ',' ',' ','☆　╱★　╱╱　╱"
echo "【完成步态识别视频分析，请到桌面查看分析结果，谢谢使用！】"
echo "╱╱　╱   ',' ',' ',' ','☆　╱★　╱╱　╱   ',' ',' ',' ','☆　╱★　╱╱　╱"
echo "--------------------------------------------------------"



