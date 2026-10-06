# Bài 4: Quản lý tiến trình nền với nohup và tín hiệu kill

## Tạo script giám sát

Tệp `loop-monitor.sh` có nội dung:

```bash
#!/bin/bash

while true; do
    echo "Thời gian hệ thống: $(date '+%Y-%m-%d %H:%M:%S %Z')" >> /tmp/monitor.log
    sleep 5
done
```

Vòng lặp ghi thời gian hiện tại vào `/tmp/monitor.log`, sau đó chờ 5 giây trước lần ghi tiếp theo.

## Cấp quyền thực thi

```bash
chmod +x loop-monitor.sh
ls -l loop-monitor.sh
```

Kết quả:

```text
CrouAn244@vps:~/homework/session_06/ex4$ chmod +x loop-monitor.sh
CrouAn244@vps:~/homework/session_06/ex4$ ls -l loop-monitor.sh
-rwxr-xr-x 1 CrouAn244 CrouAn244 135 Oct  7 00:30 loop-monitor.sh
```

## Khởi chạy tiến trình bằng nohup

```bash
nohup ./loop-monitor.sh > /dev/null 2>&1 &
echo $!
```

Kết quả:

```text
CrouAn244@vps:~/homework/session_06/ex4$ nohup ./loop-monitor.sh > /dev/null 2>&1 &
[1] 4721
CrouAn244@vps:~/homework/session_06/ex4$ echo $!
4721
```

Ký tự `&` đưa tiến trình xuống nền. Lệnh `nohup` giúp tiến trình tiếp tục chạy khi phiên SSH bị đóng. Đầu ra chuẩn và đầu ra lỗi được chuyển đến `/dev/null` vì dữ liệu giám sát đã được ghi riêng vào `/tmp/monitor.log`.

## Tìm PID và kiểm tra tiến trình

```bash
pgrep -af loop-monitor.sh
ps aux | grep '[l]oop-monitor.sh'
```

Kết quả:

```text
CrouAn244@vps:~/homework/session_06/ex4$ pgrep -af loop-monitor.sh
4721 /bin/bash ./loop-monitor.sh

CrouAn244@vps:~/homework/session_06/ex4$ ps aux | grep '[l]oop-monitor.sh'
CrouAn244  4721  0.0  0.1  7376  3328 pts/0  S  00:30  0:00 /bin/bash ./loop-monitor.sh
```

PID của tiến trình là `4721`. Cách viết mẫu tìm kiếm `'[l]oop-monitor.sh'` giúp kết quả không chứa chính tiến trình `grep`.

## Kiểm tra tệp log

```bash
tail -n 10 /tmp/monitor.log
```

Kết quả:

```text
CrouAn244@vps:~/homework/session_06/ex4$ tail -n 10 /tmp/monitor.log
Thời gian hệ thống: 2026-10-07 00:30:05 +07
Thời gian hệ thống: 2026-10-07 00:30:10 +07
Thời gian hệ thống: 2026-10-07 00:30:15 +07
Thời gian hệ thống: 2026-10-07 00:30:20 +07
Thời gian hệ thống: 2026-10-07 00:30:25 +07
Thời gian hệ thống: 2026-10-07 00:30:30 +07
Thời gian hệ thống: 2026-10-07 00:30:35 +07
Thời gian hệ thống: 2026-10-07 00:30:40 +07
Thời gian hệ thống: 2026-10-07 00:30:45 +07
Thời gian hệ thống: 2026-10-07 00:30:50 +07
```

Các dòng log cách nhau 5 giây, đúng với thời gian chờ được thiết lập trong script.

## Dừng tiến trình bằng SIGTERM

Gửi tín hiệu `SIGTERM` để yêu cầu tiến trình kết thúc an toàn:

```bash
kill -15 4721
sleep 1
ps -p 4721
```

Kết quả:

```text
CrouAn244@vps:~/homework/session_06/ex4$ kill -15 4721
[1]+  Terminated              nohup ./loop-monitor.sh > /dev/null 2>&1
CrouAn244@vps:~/homework/session_06/ex4$ sleep 1
CrouAn244@vps:~/homework/session_06/ex4$ ps -p 4721
    PID TTY          TIME CMD
```

Kết quả không còn dòng dữ liệu của PID `4721`, xác nhận tiến trình đã dừng sau khi nhận `SIGTERM`.

Chỉ sử dụng `SIGKILL` khi tiến trình vẫn còn tồn tại sau khi đã gửi `SIGTERM` và chờ kiểm tra lại:

```bash
kill -9 4721
```

`SIGKILL` buộc hệ điều hành kết thúc tiến trình ngay lập tức, vì vậy tiến trình không có cơ hội tự dọn dẹp tài nguyên trước khi dừng.
