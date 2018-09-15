#python 2.7
import requests
import time
import csv
import re
import numpy as np

url = 'https://www.sec.gov/Archives/edgar/data/937886/0001193125-07-002711.txt'
#url = 'https://www.sec.gov/Archives/edgar/data/1016538/0001016538-07-000015.txt'

class Parsing:
    def __init__(self, url):
        self.url = url
        #Read Data from URL
        headers= {'User-Agent': 'Mozilla/5.0'}
        try:
            response = requests.get(url)
            print response.status_code
            self.content = response.content
        except:
            print("URL Error!!!!")
            exit(1)
        if not self.content:
            print("URL Error!!!!")
            exit(1)
        try:
            # Read all raw data table blocks
            self.table = re.findall(r'<TABLE>\n(.*?)\n</TABLE>', self.content,  re.IGNORECASE | re.DOTALL)
        except:
            print("Table Error!!!!")
            exit(1)
        if not self.table:
            print("File has neither <TABLE> nor </TABLE>")
            exit(1)

    def get_heading(self):
        try:
            # Read the heading of tables
            self.heading = re.findall(r'(.*?)<C>\n', self.table[0],  re.IGNORECASE | re.DOTALL)
        except:
            print("Heading Parsing failed!!!")
            exit(1)
        if not self.heading:
            # File do not have <C> tag
            self.heading = re.findall(r'name of(.*?)\n\n', (self.table[0]), re.IGNORECASE | re.DOTALL)
            if not self.heading:
                print("Heading Pearsing failed!")
                exit(1)
        else:
            self.heading[0] = self.heading[0] + '<C>'
            idx = self.table[0].find('<S>')
            self.table[0] = self.table[0][idx:]
            self.title = self.parse_title_with_C(self.heading[0])

    def parse_table_with_C(self, table):
        formated_table = []
        for tab in table:
            tab_lines = tab.splitlines()
            col_location = tab_lines[0]
            idx = []
            i = col_location.find("<C>")
            while i > -1:
                idx.append(i)
                col_location = col_location[:i] + "***" + col_location[i+3:]
                i = col_location.find("<C>")
            # Check table alignment?
            if len(idx) + 1 < self.num_col:
                if len(formated_table) > 0:
                    row = np.random.randint(len(formated_table), size = 10)
                    sum_col = formated_table[row[0]]
                    for j in row:
                        for k in range(0, self.num_col):
                            sum_col[k] = sum_col[k] + formated_table[j][k]
                # Find Missing Column
                missing_col = []
                for k in range(0, len(sum_col)):
                    if len(sum_col[k]) < 3:
                        missing_col.append(k)
                for line in tab_lines[1:]:
                    row_missing = self.parse_line(line, idx)
                    for k in missing_col:
                        row_missing.insert(k, '')
                    formated_table.append(row_missing)
            else:
                for line in tab_lines[1:]:
                    formated_table.append(self.parse_line(line, idx))
        # Add row titles
        formated_table.insert(0,self.title)
        return formated_table

    def parse_title_with_C(self, heading):
        heading_lines = heading.splitlines()
        col_location = heading_lines[-1]
        idx = []
        i = col_location.find("<C>")
        while i > -1:
            idx.append(i)
            col_location = col_location[:i] + "***" + col_location[i+3:]
            i = col_location.find("<C>")
        self.num_col = len(idx) + 1
        format_line = []
        a = ['<', '>', '--']
        for line in heading_lines[::-1]:
            formarted_line = self.parse_line(line, idx)
            line1 = []
            for word in formarted_line:
                #Check if work is subtitle?
                if any(x in word for x in a):
                    line1.append('')
                else:
                    line1.append(word)
            format_line.append(line1)
        # Merge title
        title = []
        for i in range(0,self.num_col):
            for j in range(0, len(format_line)):
                if format_line[j][i]:
                    tl = "{} {} {}".format(format_line[j+2][i],format_line[j+1][i],format_line[j][i])
                    title.append(tl.strip())
                    break
        return title

    def parse_line(self, line, idx):
        formated_line = []
        pre = 0
        for i in idx:
            formated_line.append((line[pre:i]).strip())
            pre = i
        formated_line.append((line[pre:]).strip())
        return formated_line

    def write_formated_table_to_csv(self, formated_table, filename):
        with open(filename, 'wb') as f:
            writer = csv.writer(f)
            for row in formated_table:
                # row is a list of observations
                writer.writerow(row)
            f.close()
        return True

if __name__=="__main__":
    parse = Parsing(url)
    parse.get_heading()
    formated_table = parse.parse_table_with_C(parse.table)
    parse.write_formated_table_to_csv(formated_table, 'test.csv')
