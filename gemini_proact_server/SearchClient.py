import os
from tavily import TavilyClient
from dotenv import load_dotenv

from attrs import define, field, NOTHING
from typing import List, Callable, Union, Literal

@define
class SearchClient():
    '''
    - Provide internet search information/results given a query. 
    - Just use Tavily API for now, but may be extended to support other APIs such as Bing,
    or use a custom scraper to avoid request limits by external APIs.
    '''

    # input params
    api_key: str = field(default=NOTHING, eq=True)

    # internal
    tavily = field(init=False)

    def __attrs_post_init__(self):
        ''' Run right after __init__() '''
        self.tavily = TavilyClient(self.api_key)
    
    def quick_search(
        self,
        query: str,
        search_depth: Literal['basic', 'advanced'] = 'advanced',
    ) -> str:
        '''
        Use TavilyClient.qna_search() to perform a quick search with conside str output suitable for LLMs. 
        
        Args:
        query (str): The search query string.
        search_depth (Literal['basic', 'advanced'], optional): 
            The depth of the search. Can be 'basic' for a faster search or 'advanced' for a more quality search. Defaults to 'advanced'.
        '''
        result = self.tavily.qna_search(
            query=query,
            search_depth=search_depth
        )
        return result
    

    def search(
        self,
        query: str,
        search_type: Literal['regular', 'qna'] = 'qna', 
        search_depth: Literal['basic', 'advanced'] = 'advanced',
        as_str: bool = True
    ) -> Union[str, List[dict]]:
        '''
        Use Tavily.search() to perform a more detailed search with detailed and link to each site in the search result.

        Args:
            query (str): 
                The search query string.
            search_depth (Literal['basic', 'advanced'], optional): 
                The depth of the search. Can be 'basic' for a faster search or 'advanced' for a more quality search. Defaults to 'advanced'.
            as_str (bool): 
                If True, extract the content of search results to generate a single string. Otherwise, generate the raw search output of type List[dict]
        '''
        
        # search
        result = self.tavily.search(
            query = query,
            search_depth = search_depth
        )

        # convert output to str 
        if as_str and search_type == 'regular':
            # TODO: TavilyClient.search() returns a list of JSON, needs to convert it to a str
            pass 

        return result



# Test driver
if __name__ == '__main__':
    load_dotenv()
    