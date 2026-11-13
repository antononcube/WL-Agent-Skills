(* ::Package:: *)

(*
   Export the technical-note and function-reference notebooks in a paclet as
   Markdown.  This file uses only functions supplied by the Wolfram Language.

   Command-line use:

       wolframscript -file PacletMarkdownFiles.wls /path/to/MyPaclet

   The public function can also be used after Get["PacletMarkdownFiles.wls"]:

       PacletMarkdownFiles["/path/to/MyPaclet"]
*)

ClearAll[PacletMarkdownFiles, techNoteNotebookQ, functionPageNotebookQ];

PacletMarkdownFiles::usage =
  "PacletMarkdownFiles[pacletDirectory] exports every tech-note and function-page notebook in a paclet to Markdown-files. It returns an association containing the source notebook names and generated Markdown file names.";

PacletMarkdownFiles::nodir = "`1` is not a directory.";
PacletMarkdownFiles::nodocs = "No Documentation directory was found in paclet directory `1`.";
PacletMarkdownFiles::export = "Could not export `1`: `2`.";

techNoteNotebookQ[file_String] :=
  MemberQ[FileNameSplit[file], Alternatives["Tutorials", "TechNotes"]];

functionPageNotebookQ[file_String] := Module[{parts = FileNameSplit[file]},
  MemberQ[parts, "ReferencePages"] &&
    MemberQ[parts, Alternatives["Symbols", "Functions"]]
  ];

PacletMarkdownFiles[pacletDirectory_String] := Module[
  {
    paclet, documentationDirectory, markdownDirectory, notebooks,
    techNotes, functionPages, selectedNotebooks, notebookType,
    source, target, result = <||>, converted = {}, failed = {},
    relativeName, exportResult
  },

  paclet = ExpandFileName[pacletDirectory];
  If[! DirectoryQ[paclet], Message[PacletMarkdownFiles::nodir, paclet]; Return[$Failed]];

  documentationDirectory = FileNameJoin[{paclet, "Documentation"}];
  If[! DirectoryQ[documentationDirectory],
    Message[PacletMarkdownFiles::nodocs, paclet];
    Return[$Failed]
    ];

  notebooks = FileNames["*.nb", documentationDirectory, Infinity];
  techNotes = Select[notebooks, techNoteNotebookQ];
  functionPages = Select[notebooks, functionPageNotebookQ];
  selectedNotebooks = DeleteDuplicates[Join[techNotes, functionPages]];

  markdownDirectory = FileNameJoin[{paclet, "Markdown-files"}];
  If[! DirectoryQ[markdownDirectory],
    CreateDirectory[markdownDirectory, CreateIntermediateDirectories -> True]
    ];

  Print["Tech-note notebooks:"];
  Scan[Print, techNotes];
  Print["Function-page notebooks:"];
  Scan[Print, functionPages];

  Do[
    notebookType = If[MemberQ[techNotes, source], "tech-note", "function-page"];
    relativeName = FileBaseName[source] <> ".md";
    target = FileNameJoin[{markdownDirectory, relativeName}];
    (* A paclet can theoretically contain a tech note and a reference page
       with the same base name.  Keep both files without changing the normal
       (non-colliding) Markdown-files/<name>.md output convention. *)
    If[MemberQ[converted, target],
      target = FileNameJoin[{markdownDirectory, notebookType <> "-" <> relativeName}]
      ];

    exportResult = Quiet@Check[
      Export[target, Import[source, "NB"], "Markdown"],
      $Failed
      ];
    If[exportResult === $Failed,
      AppendTo[failed, source];
      Message[PacletMarkdownFiles::export, source, "the notebook could not be converted"],
      AppendTo[converted, target]
      ],
    {source, selectedNotebooks}
    ];

  result = <|
    "TechNoteNotebooks" -> techNotes,
    "FunctionPageNotebooks" -> functionPages,
    "MarkdownFiles" -> converted,
    "FailedNotebooks" -> failed
    |>;

  Print["Markdown files written to: " <> markdownDirectory];
  result
  ];

(* 
  Pick the one argument supplied after the script name by wolframscript.  
  The test also lets this file be loaded with Get without running the export. 
*)
If[MemberQ[$ScriptCommandLine, "-file"],
  With[{arguments = Rest@Drop[$ScriptCommandLine, First@FirstPosition[$ScriptCommandLine, "-file"]]},
    If[Length[arguments] == 1,
      PacletMarkdownFiles[First[arguments]],
      Print["Usage: wolframscript -file PacletMarkdownFiles.wls <paclet-directory>"]
      ]
    ]
  ];
