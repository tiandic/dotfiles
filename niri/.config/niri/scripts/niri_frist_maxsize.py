#!/bin/python3

import json
import os
import socket

class Niri_con:
    def __init__(self,niri_socket_path) -> None:
        self.sock=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM)
        self.sock.connect(niri_socket_path)
        self.chunk=b""

    def read_line(self):
        line=b""
        while not b'\n' in self.chunk:
            self.chunk+=self.sock.recv(4096)
            if not self.chunk:
                break
        line,self.chunk=self.chunk.split(b"\n",1)
        return json.loads(line.decode())

    def send_cmd(self,cmd):
        self.sock.sendall((json.dumps(cmd)+"\n").encode())

    def cmd(self,cmd):
        self.send_cmd(cmd)
        return self.read_line()

def get_workspace_windows(con:Niri_con,id,windows=None):
    if windows==None:
        windows=get_all_windows(con)
    return [ w for w in windows if w["workspace_id"]==id ]

def get_focused_workspace(con:Niri_con):
    workspaces = con.cmd("Workspaces")

    for k,v in workspaces.items():
        workspaces=v["Workspaces"]

    for v in workspaces:
        if v["is_focused"]:
            return v

def get_focused_workspace_id(con:Niri_con):
    workspace=get_focused_workspace(con)
    return workspace["id"]

def get_focused_window_id(con:Niri_con):
    windows=get_all_windows(con)
    for w in windows:
        if w["is_focused"]:
            return w["id"]

def set_window_maxsize(con:Niri_con,id,workspace_id):
    global frist_window_ids
    save_current_workspace_id(con)
    old_frist_window_id=-1
    if str(workspace_id) in frist_window_ids:
        old_frist_window_id=frist_window_ids[str(workspace_id)]
    if old_frist_window_id == id:
        return
    frist_window_ids[str(workspace_id)]=id
    con.cmd({"Action": {"FocusWindow": {"id": id}}})
    con.cmd({"Action": {"MaximizeColumn": {}}})
    recover_current_workspace(con)

def set_frist_window_half(con:Niri_con,workspace_id):
    if not str(workspace_id) in frist_window_ids:
        return
    save_current_workspace_id(con) # 改变窗口大小需要先聚焦到目标窗口,这会改变聚焦的工作区,出现进入niri时,聚焦到其他工作区,而非需要的工作区,所以需要先记录当前工作区
    frist_window_id=frist_window_ids[str(workspace_id)]
    del frist_window_ids[str(workspace_id)]
    new_window_id=get_focused_window_id(con) # 打开新窗口时,会聚焦到新窗口,但调整旧窗口大小需要聚焦到旧窗口,在这里获取新窗口id,然后在调整旧窗口大小后恢复聚焦

    con.cmd({"Action": {"FocusWindow": {"id": frist_window_id}}})
    con.cmd({"Action": {"SetColumnWidth": {"change": {"SetProportion": 50.0}}}})

    con.cmd({"Action": {"FocusWindow": {"id": new_window_id}}})
    recover_current_workspace(con)

def save_current_workspace_id(con):
    global current_workspace_id
    current_workspace_id=get_focused_workspace_id(con)

def recover_current_workspace(con:Niri_con):
    global current_workspace_id
    if current_workspace_id!=-1:
        con.cmd({"Action": {"FocusWorkspace": {"reference": {"Id": current_workspace_id}}}})
        current_workspace_id=-1

def get_all_windows(con:Niri_con):
    windows=con.cmd("Windows")
    for k,v in windows.items():
        windows=v["Windows"]
    return windows

def update_all_windows():
    global all_windows
    all_windows=get_all_windows(c2)

def get_workspace_id(id):
    for w in all_windows:
        if w["id"]==id:
            return w["workspace_id"]


c=Niri_con(os.environ["NIRI_SOCKET"])
c2=Niri_con(os.environ["NIRI_SOCKET"])
all_windows=[]
frist_window_ids={}
current_workspace_id=-1

def main():
    c.send_cmd("EventStream")
    update_all_windows()    # all_windows 用于获取关闭窗口的所在工作区 id

    while True:
        for k,v in c.read_line().items():
            print("event: "+k)
            if k in ["WindowOpenedOrChanged"]:
                update_all_windows()
                v=v["window"]
                windows=get_workspace_windows(c2,v["workspace_id"]) # 获取当前事件的工作区的所有窗口,用于判断应该最大化还是占一半
                if len(windows)==1:
                    # 如果只有工作区只有一个窗口则最大化
                    set_window_maxsize(c2,windows[0]["id"],v["workspace_id"])
                elif len(windows)>1:
                    # 如果有多个则各占显示器的一半
                    set_frist_window_half(c2,v["workspace_id"])

            elif k in ["WindowClosed"]:
                workspace_id=get_workspace_id(v["id"])
                update_all_windows()
                windows=get_workspace_windows(c2,workspace_id) # 获取当前事件的所在工作区
                if len(windows)==1:
                    set_window_maxsize(c2,windows[0]["id"],workspace_id)

main()
