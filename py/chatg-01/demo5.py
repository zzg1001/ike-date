import tkinter as tk
from tkinter import scrolledtext, filedialog, messagebox

class ChatApp:
    def __init__(self, root):
        self.root = root
        self.root.title("聊天对话框")

        # 聊天区域
        self.chat_area = scrolledtext.ScrolledText(root, wrap=tk.WORD)
        self.chat_area.pack(padx=10, pady=10, fill=tk.BOTH, expand=True)
        self.chat_area.config(state=tk.DISABLED)

        # 输入框
        self.message_entry = tk.Entry(root)
        self.message_entry.pack(padx=10, pady=10, fill=tk.X)
        self.message_entry.bind("<Return>", self.send_message)

        # 发送按钮
        self.send_button = tk.Button(root, text="发送", command=self.send_message)
        self.send_button.pack(padx=10, pady=10)

        # 下载按钮
        self.download_button = tk.Button(root, text="下载聊天记录", command=self.download_chat)
        self.download_button.pack(padx=10, pady=10)

    def send_message(self, event=None):
        message = self.message_entry.get()
        if message:
            self.chat_area.config(state=tk.NORMAL)
            self.chat_area.insert(tk.END, "你: " + message + "\n")
            self.chat_area.config(state=tk.DISABLED)
            self.chat_area.see(tk.END)  # 滚动到最后一行
            self.message_entry.delete(0, tk.END)  # 清空输入框

    def download_chat(self):
        chat_content = self.chat_area.get("1.0", tk.END)
        file_path = filedialog.asksaveasfilename(defaultextension=".txt",
                                                   filetypes=[("Text files", "*.txt")])
        if file_path:
            try:
                with open(file_path, "w", encoding="utf-8") as file:
                    file.write(chat_content)
                messagebox.showinfo("成功", "聊天记录已保存！")
            except Exception as e:
                messagebox.showerror("错误", f"保存聊天记录时出错: {str(e)}")

if __name__ == "__main__":
    root = tk.Tk()
    app = ChatApp(root)
    root.mainloop()