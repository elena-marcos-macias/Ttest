# Ttest - ReadMe

This code is designed to perform a two group comparison, or its non-parametric alternative. In other words, it compares data across different experimental groups for a single variable, but it does **not** compare repeated measures.

## Prerequisites

- MATLAB must be installed (this code was developed using MATLAB R2024a).
- The data to be analyzed must be contained in a single sheet of an Excel file (.xlsx). The file name must **not** contain spaces, punctuation marks, or special characters. The contents of the table **MUST** be in english.  
  - **NO cells should be empty** unless the whole row is to be discarded. This script completely deletes a row if any of its cells are empty.
  - The **first row** of the file must contain the variable names.  
  - Each **subsequent row** corresponds to one subject in the study.  
  - Each **column** represents a variable to be analyzed.  
  - One of the variables must be a **categorical grouping variable**, which is used to determine each subject’s group membership. *In this case, the variable “Genotipo” in column A serves as the categorical variable.*
  - One of the variables can be another **categorical variable** which allow us to highlight certain subjects. *In column B, the variable "Muerte" indicates which animals died spontaneously during the experiment.*
  <img width="1172" height="569" alt="image" src="https://github.com/user-attachments/assets/97c14b2b-31b2-40e8-8f6a-3f5f7235fd98" />



## Downloading the Repository

- Download the `.zip` file using the "CODE > Local > Download ZIP" option and save it to your computer.
- Extract the contents of the `.zip` file. The directory should contain the following structure:

  - 📁 `data`: the only folder the user needs to modify.
    - The file `instructionsANOVA1f.json` is a text file that **must** be edited by the user.
    - Paste your Excel file with the data into this folder.
  - 📁 `requirements`: external functions necessary for the script to run.
  - 📁 `results`: output folder where the resulting Excel (.xlsx) and MATLAB figure (.fig) files will be saved.
  - 📁 `utils`: internal functions required for the script.
  - `ANOVA1f.m`: the main MATLAB script to be executed.
  - `README.md`: this documentation file.
  - There may be additional files not relevant to the user. **Do not delete them.**

## Importing the Data

Open the `data` folder and copy your Excel data file into it.

## Editing the JSON File

Within the `data` folder, open the file `instructionsANOVA1f.json`. If you do not have a code editor (such as Visual Studio Code), you may use Notepad. You will see a structure similar to this:

<img width="865" height="914" alt="image" src="https://github.com/user-attachments/assets/e6d78cb6-8338-4f21-b413-c1011ac26f35" />


Follow these steps to modify the JSON file appropriately:

1. **Preliminary Notes:**
   - **Do not edit** any element to the **left** of the colons (`:`). Only modify the elements on the **right**.
   - If the element is **text**, it must be enclosed in double quotation marks (e.g., `"FUS_20250527.xlsx"`).
   - If the element is **numeric**, it must be enclosed in square brackets (e.g., `[3, 19]`).
   - The elements are organized in blocks enclosed in curly braces `{}` or square brackets `[]`—**do not alter** this structure.
   - Elements within the same block must be separated by commas `,`, **except the last one**.

2.  **"inputDataSelection"**
  -  `"fileName"`: The name of the Excel file you copied into the `data` folder. It must match exactly, including the `.xlsx` extension. It is recommended to copy and paste the file name rather than typing it manually.
  -  `"columnCriteria"`: Criteria for distinguishing columns that contain data that is going to be used to mathematically operate from those that do not (e.g., grouping variable or subject ID columns).
      - `"target_columns"`: Specifies the columns to be analyzed. Two methods are available:
          - **Text**: A shared keyword present in all column names to be included (case-sensitive).
          *Example: if columns are named Mean_1, Mean_2, ..., use `"Mean"`.*
          - **Numeric**: Specify the column ranges using pairs of numbers (start and end column indices).  
          *Example: to include columns D–I and N–V, write `[4,9,14,22]`.*
      - `"ignore_columns"`: Specifies the columns to exclude from analysis. Two options:
          - **Text**: If using the text method above for target columns, enter `"None"`.
          - **Numeric**: Specify the ranges of columns to be ignored using pairs of indices.  
          *Example: to ignore columns A–C and J–M, write `[1,3,10,13]`.*
  -  `"groupName"`: Name of the grouping variable. This must match the column header in the Excel file.  
   *In the example data, this would be column A, labeled "Genotipo".*
  -  `"groupOrder"`: List the categories of the grouping variable in the order you want them displayed in the graph (up to four categories). **All of the existing categories must be listed, regardless of you wanting them to appear in the graph or not.** ~LO QUIERO CAMBIAR PARA QUE PUEDAS SELECCIONAR CATEGORÍAS Y NO TENENGAS QUE USAR TODAS~
   *Example: `["WT", "Het", "Hom"]`.*
  -  `"groupControl"`: Specify the groups to be treated as control groups for the post-hoc Dunnett test (and its non-parametric equivalent).

3  **"outputFileNames"**:
  - `"excelFileName"`: File name (including `.xlsx` extension) for the Excel file containing the results from the analysis.  
  -  `"descriptiveStatistics"`: name of the Sheet containing the descriptive statistics, in the results' Excel file. The output includes group sample sizes, means, and standard deviations.
  -  `"varianceAnalysis"`: name of the Sheet containing the ANOVA (or non-parametric equivalent) results, in the results' Excel file.  Includes F-statistic (for ANOVA), Chi² (for non-parametric), p-values, and significance indicators.
  -  `"posthoc_AllComparisons"`: name of the Sheet containing the results from Tukey’s post-hoc test (and non-parametric alternative), in the results' Excel file. Includes p-values and significance indicators.
  -  `"posthoc_vsControl1"`: name of the Sheet containing the results from the Dunnett post-hoc test against `"controlGroup1"` (and its non-parametric alternative), in the results' Excel file. Includes p-values and significance indicators.
  -  `"posthoc_vsControl2"`: name of the Sheet containing the results from the Dunnett post-hoc test against `"controlGroup2"` (and its non-parametric alternative), in the results' Excel file. Includes p-values and significance indicators.
  -  `"graphBar"`: File name (with `.fig` extension) for the MATLAB figure output.

 4 **`"wantGraph"`**: complete with yes or no, depending on wheather or not you want to generate a graph with the mean and standar deviation results. The graph also includes the individual points for each subject and significance markers (ANOVA results). Here is an example of said graph.
 
 ![image](https://github.com/user-attachments/assets/e419d805-6402-4252-b432-cf312358dcf2)
 
 5 **"graphSpecifications":**
  - `"graphTitle"`: title of the graph.  
  - `"xAxisLabel"` and `"yAxisLabel"`: labels for the X and Y axes, respectively.
  - "highlightVariable":
      - `"showHighlightVariable"`: complete with yes or no, depending on wheather or not you want to mark differently the individual points for those subjects for which the `"highlightVariable"`is true. If you write "yes" these point will be coloured in red. For the time being you can't choose the color.
      - `"highlightVariable"`: name of said variable on the input excel archive (*e.g. in column B "Death" would be the highlight variable*).
      - `"trueHighlightVariable"`: string that, in the input excel file, represents those subjects for which the highlight variable is true (*e.g. in column B "yes" marks those subjects for which "Death" is true*).
  - "GroupN": next there are a series of paragraphs named Group and a number. The number indicates the order in which the groups are going to be represented in the graph. In other words, if we've stablished the `"groupOrder"` as `["WT", "Het", "Hom"]`, "WT" is going to be represented with the characteristics specified in `"Group1"`, "Het" with `"Group2"` and "Hom" with `"Group3"`.

    Don't worry if you don't have enough experimental groups to complete the eight posible groups of the .json archive. Simply leave the extra ones as they are.
      - `"fillColor"` and `"lineColor"`: string that corresponds to a color from this color palete.
        <img width="1546" height="644" alt="image" src="https://github.com/user-attachments/assets/b38c6f86-f3ba-4eee-97ba-8272407b30db" />
      - `"markerShape"`: complete with "^" to use triangles, "o" to use cicles and "s" for squares.
      - `"filledStatus"`: complete with "filled" if you want the shapes to be coloured in and "none" if not.

Once all necessary fields have been edited, save the `.json` file. It is not necessary to close the file before running the script, but it **must** be saved.

~Tb me gustaría hacer opcional que aparezca el gráfico ¿if?~

## Running the Script

Open the `ANOVA1f.m` script in the main directory using MATLAB and run it by clicking the **RUN** button.
