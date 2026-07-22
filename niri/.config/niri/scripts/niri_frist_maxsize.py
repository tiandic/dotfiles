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

def get_all_workspaces(con:Niri_con):
    workspaces=con.cmd("Workspaces")
    for k,v in workspaces.items():
        return v["Workspaces"]

def get_workspace(con:Niri_con,id):
    workspaces=get_all_workspaces(con)
    for workspace in workspaces:
        if workspace["id"]==id:
            return workspace

def get_window_info(con:Niri_con,id):
    windows=get_all_windows(con)
    for w in windows:
        if w["id"]==id:
            return w

def get_all_output(con:Niri_con):
    outputs=con.cmd("Outputs")
    for k,v in outputs.items():
        return v["Outputs"]

def get_output_info(con:Niri_con,output_name):
    outputs=get_all_output(con)
    return outputs[output_name]

def is_MaximizeColumn(con:Niri_con,id):
    w=get_window_info(con,id)
    workspace_id=-1
    window_width=-1
    window_height=-1
    
    if w:
        workspace_id=w["workspace_id"]
        window_width=w["layout"]["tile_size"][0]
        window_height=w["layout"]["tile_size"][1]

    workspace=get_workspace(con,workspace_id)
    output_name=workspace["output"]
    output=get_output_info(con,output_name)

    if (window_width+50>=output["logical"]["width"]) and (window_height+50>=output["logical"]["height"]):
        return True
    return False

def set_window_maxsize(con:Niri_con,id,workspace_id):
    global frist_window_ids

    # 判断是否已经被代码设置为最大化
    if is_MaximizeColumn(con,id):
        return

    save_current_workspace_id(con)
    frist_window_ids[str(workspace_id)]=id
    con.cmd({"Action": {"FocusWindow": {"id": id}}})
    con.cmd({"Action": {"MaximizeColumn": {}}})
    recover_current_workspace(con)

def set_frist_window_half(con:Niri_con,workspace_id):
    if not str(workspace_id) in frist_window_ids:
        return
    save_current_workspace_id(con)
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


c=Niri_con(os.environ["NIRI_SOCKET"])    # 用于事件流
c2=Niri_con(os.environ["NIRI_SOCKET"])   # 用于其他操作,一个套接字发出获取事件流的请求后就无法再进行其他操作
all_windows=[]           # 用于获取关闭窗口的所在工作区 id, 关闭窗口事件只返回被关闭窗口的id,所以需要在关闭前记录下该窗口的其他属性
frist_window_ids={} # 用于记录每个工作区只有一个窗口时,该窗口的id,当工作区不再只有一个窗口时,该键值会被删除
current_workspace_id=-1             # 记录当前聚焦工作区的id, 改变窗口大小需要先聚焦到目标窗口,这会改变聚焦的工作区,会出现进入niri时,聚焦到其他工作区,而非需要的工作区的问题,所以需要先记录当前工作区

def main():
    c.send_cmd("EventStream")
    update_all_windows()

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
