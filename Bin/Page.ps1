

Function New-BootStrapModal {
    [Cmdletbinding()]
    Param(

    [String]$Id
    )

    div -Class "modal fade" -id $Id -Attributes @{tabindex="-1";}
}

<#
<!-- Button trigger modal -->
<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#exampleModal">
  Launch demo modal
</button>

<!-- Modal -->
<div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLabel">Modal title</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        ...
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary">Save changes</button>
      </div>
    </div>
  </div>
</div>

#>

$HTML = html {
   
    Include -Name headPart

    body {

        div -Class "container" -Content {
     
            include -Name TopPage

            h3 -Content {
                "Events"
            }
            
            $AllAgendaFiles = gci ../Agenda/ -File | sort Name -Descending



            $AllObjects = @()

            Foreach($AgendaFile in $AllAgendaFiles){
                $Hash = @{}
                
                $Naming = $AgendaFile.Name.Split("-")
                $Hash.Date = $Naming[1]
                $Hash.Type = $Naming[2]
                $Hash.Title = $Naming[3].Replace("_"," ")
                $Hash.DetailsUrl = "Details/" + $($AgendaFile.Name.Replace(".json",".html"))
                $Link = $null
                $Link = a -href $Hash.DetailsUrl -Content {
                    button -Content {
                        "Details"
                    } -Class "btn btn-outline-primary"
                } -Target _blank 

                $Hash.Link = $Link
                $jsondata = gc $AgendaFile.FullName -raw | convertfrom-json
                $Hash.TalkDetails = $jsondata
                $RecordingLink = a -href "$($jsondata.recording)" -Content {
                    button -Content {
                        "Recording"
                    } -Class "btn btn-outline-primary"
                } -Target _blank
                
                $Hash.Video = $RecordingLink
                $AllObjects += New-Object -TypeName psobject -Property $Hash
                
                

                $jsondata = $null
                $Link = $null
                $RecordingLink = $null
            }

            ConvertTo-PSHTMLTable -Object $AllObjects -Properties Date,Type,Title,Link,Video -TableClass "table" -TheadClass "thead-dark"

            #Create details page
            foreach($meetup in $AllObjects){

                $DetailPage = html {
                    include headpart
                    body {
                        if($meetup.Type -eq 'Lightning'){

                            h3 -Content {
                                "{0} - {1}" -f $meetup.Date,$meetup.Type,$meetup.Title
                            }

                            ConvertTo-PSHTMLTable -Object $meetup.TalkDetails -Properties Id,Title,Abstract,PresenterName,Twitter,Website,Recording -TableClass "table" -TheadClass "thead-dark"
                        }else{
                            h3 -Content {
                                "{0} - {1}" -f $meetup.Date,$meetup.Type,$meetup.Title
                            }
                            ConvertTo-PSHTMLTable -Object $meetup.TalkDetails -Properties Id,Title,Abstract,PresenterName,Twitter,Website,Recording -TableClass "table" -TheadClass "thead-dark"
                        }
                    }
                    include BottomPage
                }
                $Current = Get-Location
                $Detailsfolder = $Current.Path.Replace('Bin','Agenda')
                $FilePath = Join-Path $Detailsfolder -ChildPath $meetup.DetailsUrl
                $DetailPage | out-File -Filepath $FilePath -Encoding utf8
            }


        }#End container 

    }
       
        
    
    
    Include -Name BottomPage
}

#Out-PSHTMLDocument -OutPath 'Index.html' -HTMLDocument $HTML -Show
$HTML | out-File -Filepath ..\index.html -Encoding utf8
invoke-item ..\index.html